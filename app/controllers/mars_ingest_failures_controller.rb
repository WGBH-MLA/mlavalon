class MarsIngestFailuresController < ApplicationController
  before_action :authenticate_user!

  def index
    @mars_ingest_failures = MarsIngestFailure.order(created_at: :desc).all
  end

  def show
    @mars_ingest_failure = MarsIngestFailure.find(params[:id])
    render 'show', layout: false, content_type: 'text/plain'
  end
end
