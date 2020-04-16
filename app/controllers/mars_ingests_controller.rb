class MarsIngestsController < ApplicationController
  before_action :authenticate_user!

  after_create do
    manifest.rows.each do |row|
      mars_ingest_item = MarsIngestItem.new(status: 'enqueued')
      mars_ingest_item.csv_header_array = manifest.headers
      mars_ingest_item.csv_value_array = row
      mars_ingest_item.mars_ingest_id = id
      mars_ingest_item.save!
    end
  end

  def index
    @mars_ingests = MarsIngest.all

    respond_to do |format|
      format.html
      format.json { render json: @mars_ingests }
    end
  end

  def show
    @mars_ingest = MarsIngest.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: @mars_ingest }
    end
  end

  def create
    @mars_ingest = MarsIngest.new params.require(:mars_ingest).permit(:manifest_url)
    if @mars_ingest.save
      start_ingest(@mars_ingest)
      render json: { id: @mars_ingest.id }, status: 200
    else
      render json: { errors: @mars_ingest.errors.messages.values.flatten }, status: 422
    end
  end

  private

    def start_ingest(mars_ingest)
      mars_ingest.mars_ingest_items.each do |mars_ingest_item|
        job_id = MarsIngestItemJob.new(mars_ingest_item.id).perform_later
        Rails.logger.info("Started MarsIngestItemJob with jid #{job_id} from MarsIngestItem #{mars_ingest_item.id}")
      end
    end
end
