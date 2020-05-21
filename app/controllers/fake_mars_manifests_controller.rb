require_relative '../../spec/support/mars_manifest_faker'

class FakeMarsManifestsController < ApplicationController
  def index
    size = params.fetch(:size, 10)
    fake_csv = MarsManifestFaker.new(size: size)
    filename = "fake_mars_manifest.#{size}_rows.csv"
    respond_to do |format|
      format.csv { render plain: fake_csv.to_s, content_type: 'text/plain' }
    end
  end
end
