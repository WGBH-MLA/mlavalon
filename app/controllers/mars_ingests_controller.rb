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
end