class MarsIngestsController < ApplicationController
  before_action :get_mars_ingest, only: [:show, :destroy]

  def get_mars_ingest
    @mars_ingest = MarsIngest.find(params[:id])
  end

  def new
    @mars_ingest = MarsIngest.new
  end

  def create
    @mars_ingest = MarsIngest.new(mars_ingest_params)

    # validations located on model
    if @mars_ingest.save

      @mars_ingest.start_ingest

      redirect_to mars_ingest_path(@mars_ingest)
    else
      redirect_to mars_ingests_path
    end
  end

  def update
    # change status, errors, etc
  end

  def index
    @mars_ingests = MarsIngest.all
  end

  def show
    
  end

  def destroy
    # if some access thingy
    @mars_ingest.destroy
    redirect_to mars_ingest_index
  end

  private

  def mars_ingest_params
    params.require(:mars_ingest).permit(:input_filename, :number_of_items, :error, :status)
  end
end