class MarsIngest < ActiveRecord::Base


  has_many :mars_ingest_items

  after_create do
    manifest.rows.each do |row|
      mars_ingest_item = MarsIngestItem.new(status: 'enqueued')
      mars_ingest_item.csv_header_array = manifest.headers.clone
      mars_ingest_item.csv_value_array = row
      mars_ingest_item.mars_ingest_id = id
      mars_ingest_item.save!
    end
  end

  validates :manifest_url, presence: true
  validate :validate_manifest

  private

    def validate_manifest
      unless manifest.valid?
        manifest.errors.each do |_field, msgs|
          errors.add(:manifest, msgs)
        end
      end
    end

    def manifest
      @manifest ||= MarsManifest.new(url: manifest_url)
    end
end
