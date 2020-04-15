class MarsIngestItemJob < ActiveJob::Base
  queue_as :mars_ingest_item_job

  before_perform do
    set_processing_status
  end

  after_enqueue do
    set_enqueued_status
  end

  after_perform do
    set_final_status
  end

  rescue_from(StandardError) do |exception|
    ingest_item = MarsIngestItem.find(id)

    raise exception unless ingest_item

    error_msg = exception.message
    error_msg += "\n\n#{exception.backtrace.join("\n")}" if Rails.env == "development"
    ingest_item.update(status: 'failed', error: error_msg)
  end

  def perform(id)
    ingest_item = MarsIngestItem.find(id)
    ingest_item.update(job_id: self.job_id) if ingest_item.job_id == nil

    ingest_one_record(ingest_item, ingest_item.row_payload)
  end

  def set_processing_status
    ingest_item = MarsIngestItem.find(arguments.first)
    ingest_item.update(status: 'processing')
  end

  def set_enqueued_status
    ingest_item = MarsIngestItem.find(arguments.first)
    ingest_item.update(status: 'enqueued')
  end

  def set_final_status
    ingest_item = MarsIngestItem.find(arguments.first)
    return ingest_item.update(status: 'failed') if ingest_item.error.present?
    ingest_item.update(status: 'succeeded')
  end

  def ingest_one_record(ingest_item, payload)
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

    send_request(ingest_item, params)
  end

  def send_request(ingest_item, params)
    JSON.parse(RestClient::Request.execute(params))
  rescue => e
    ingest_item.update(error: "#{e.class}: #{e.message}\n API Response: #{e.response}")
  end
end
