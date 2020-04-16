class MarsIngest < ActiveRecord::Base
  validate :validate_manifest

  has_many :mars_ingest_items

  def validate_manifest
    unless manifest.valid?
      manifest.errors.each do |_field, msgs|
        errors.add(:manifest, msgs)
      end
    end
  end

  private

    def manifest
      @manifest ||= MarsManifest.new(url: manifest_url)
    end
end
