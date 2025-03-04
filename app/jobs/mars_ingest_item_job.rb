class MarsIngestItemJob < ActiveJob::Base
  MLAVALON_HOST = "mlavalon_avalon_1"
  queue_as :mars_ingest_item_job

  after_enqueue { update_status 'enqueued' }

  before_perform { update_status 'processing' }

  after_perform do
    update_status 'succeeded'
    update_ingest_if_concluded( MarsIngestItem.find(arguments.first).mars_ingest )
  end

  rescue_from(StandardError) do |exception|
    error_message = extract_error_message(exception)
    logger.error "#{error_message}\n\n#{exception.backtrace.join("\n")}"
    update_status 'failed', error_message
    update_ingest_if_concluded( MarsIngestItem.find(arguments.first).mars_ingest )
  end

  def perform(id)
    ingest_item = MarsIngestItem.find(id)
    logger.info "started job, found #{ingest_item.inspect}"
    ingest_item.update(job_id: self.job_id) if ingest_item.job_id == nil
    logger.info "updated job with #{self.job_id}"


    media_object_id = existing_record?(ingest_item.media_pim_id)
    if(media_object_id)

      # delete this whenveers convenient
      BulkActionJobs::Delete.perform_later [media_object_id], nil
    end

    # create new record
    ingest_payload(ingest_item.row_payload)
  end

  private
    def update_ingest_if_concluded(mars_ingest)
      mars_ingest.update(completed: true) unless mars_ingest.in_progress?
    end

    def update_status(status, error_msg='')
      raise ArgumentError, "Unrecognized status for MarsIngestItem: '#{status}'" unless MarsIngestItem::STATUSES.include? status
      # TODO: Consider logging here as well.
      MarsIngestItem.update(arguments.first, status: status, error: error_msg)
    end

    def ingest_payload(payload)
      logger.info "Trying to Ingest Payload"
      host = Rails.env.development? ? 'mlavalon_avalon_1:3000' : '127.0.0.1:3000'

      params = {
        method: :post,
        url: "http://#{host}/media_objects.json",
        payload: payload,
        headers: {
          content_type: :json,
          accept: :json,
          # :'Avalon-Api-Key' => ENV['AVALON_API_KEY']
          :'Avalon-Api-Key' => '9fcee031d3f8daeb26f320b9f2e7927fc4261b667de8cc3706a9dcfec04b411414fee426140d3333819b064c9e74ee322bf81ae7524722d669c92d2e33724314'
        },
        verify_ssl: false,
        timeout: -1
      }
      # Call the Avalon Ingest API with our payload.
      resp = RestClient::Request.execute(params)
      JSON.parse(resp)
    end

    def existing_record?(media_pim_id)
      # mo = MediaObject.where(media_pim_id: media_pim_id)
      solr = RSolr.connect(url: ENV['SOLR_URL'])
      searchy = solr.get('select', params: { q: "media_pim_id:#{media_pim_id}"})
      searchy["response"]["docs"][0]["id"] if searchy && searchy["response"] && searchy["response"]["docs"] && searchy["response"]["docs"][0] && searchy["response"]["docs"][0]["id"]
    end

    # @return [JSON, String] if the exception has a JSON response body with an
    #   'errors' key, then fetch and return it. Otherwise, just return the
    #   original exception message.
    def extract_error_message(exception)
      JSON.parse(exception.response.body)['errors'].to_json
    rescue
      exception.message
    end
end
