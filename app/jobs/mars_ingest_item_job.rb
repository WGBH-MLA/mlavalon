class MarsIngestItemJob < ActiveJob::Base
  queue_as :mars_ingest_item_job

  after_enqueue { update_status 'enqueued' }

  before_perform { update_status 'processing' }

  after_perform { update_status 'succeeded' }

  rescue_from(StandardError) do |exception|
    error_message = extract_error_message(exception)
    Rails.logger.error "#{error_message}\n\n#{exception.backtrace.join("\n")}"
    update_status 'failed', error_message
  end

  def perform(id)
    ingest_item = MarsIngestItem.find(id)
    ingest_item.update(job_id: self.job_id) if ingest_item.job_id == nil
    ingest_payload(ingest_item.row_payload)
  end

  private

    def update_status(status, error_msg='')
      raise ArgumentError, "Unrecognized status for MarsIngestItem: '#{status}'" unless MarsIngestItem::STATUSES.include? status
      # TODO: Consider logging here as well, ad
      MarsIngestItem.update(arguments.first, status: status, error: error_msg)
    end

    def ingest_payload(payload)
      port = '3000'
      params = {
        method: :post,
        url: "http://localhost:#{port}/media_objects.json",
        payload: payload,
        headers: {
          content_type: :json,
          accept: :json,
          :'Avalon-Api-Key' => ENV['AVALON_API_KEY']
        },
        verify_ssl: false,
        timeout: 15
      }

      JSON.parse(RestClient::Request.execute(params))
    end

    # NOTE: this MUST not raise an exception, as it is used inside of the
    # rescue_from block. This is only to extract a more meaninful error from
    # a JSON resonse. But if we can't, then resort to the original error msg.
    def extract_error_message(exception)
      JSON.parse(exception.response.body)['errors'].to_json
    rescue
      exception.message
    end
end
