class MarsIngestsController < ApplicationController
  before_action :authenticate_user!

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
      @mars_ingest.start
      render json: { id: @mars_ingest.id }, status: 200
    else
      render json: { errors: @mars_ingest.errors.messages.values.flatten }, status: 422
    end
  end
end
