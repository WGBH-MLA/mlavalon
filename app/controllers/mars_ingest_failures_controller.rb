class MarsIngestFailuresController < ApplicationController
  before_action :authenticate_user!

  def index
    @mars_ingest_failures = MarsIngestFailure.order(created_at: :desc).all

    respond_to do |format|
      format.html
      format.json { render json: @mars_ingest_failures }
    end
  end

  def show
    @mars_ingest_failure = MarsIngestFailure.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: @mars_ingest_failure.to_json }
    end
  end

  # def create
  #   micount = MarsIngest.where(completed: false).count
  #   unless micount < 3
  #     Rails.logger.info "Too Many MarsIngests currently running (#{micount})"
  #     return render json: { errors: ["Too Many MarsIngests currently running (#{micount})"]}, status: 503 
  #   end

  #   @mars_ingest = MarsIngest.new params.require(:mars_ingest).permit(:manifest_url)
  #   @mars_ingest.submitter_id = current_user.id

  #   if @mars_ingest.save
  #     start_ingest(@mars_ingest)
  #     render json: { id: @mars_ingest.id }, status: 200
  #   else
  #     Rails.logger.info "MarsIngest could not be saved: (#{ @mars_ingest.errors.messages.values.flatten })"
  #     # save error text!
  #     MarsIngestFailure.create(manifest_url: @mars_ingest.manifest_url, error_text: @mars_ingest.errors.messages.values.flatten)
  #     render json: { errors: @mars_ingest.errors.messages.values.flatten }, status: 422
  #   end
  # rescue => e
  #   error_msg = "Unexpected Error: #{e.class}: #{e.message}"
  #   Rails.logger.error("#{e.class}: #{e.message}\n\nBacktrace:\n#{e.backtrace.join("\n")}")
  #   render json: { errors: [error_msg] }, status: 422
  # end

end
