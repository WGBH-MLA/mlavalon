class FakeMarsManifestsController < ApplicationController
  before_filter :disallow_on_production

  def index
    size = params.fetch(:size, 10)
    fake_csv = MarsManifestFaker.new(size: size)
    filename = "fake_mars_manifest.#{size}_rows.csv"
    respond_to do |format|
      format.csv { render plain: fake_csv.to_s, content_type: 'text/plain' }
    end
  end

  private

    def disallow_on_production
      if Rails.env.production?
        head :bad_request
      else
        require_relative '../../spec/support/mars_manifest_faker'
      end
    end
end
