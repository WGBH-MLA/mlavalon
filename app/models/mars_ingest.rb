class MarsIngest < ActiveRecord::Base
  validate :validate_manifest

  has_many :mars_ingest_items, -> { order('id ASC') }

  after_create do
    manifest.rows.each do |row|
      mars_ingest_item = MarsIngestItem.new(status: 'enqueued')
      mars_ingest_item.csv_header_array = manifest.headers.clone
      mars_ingest_item.csv_value_array = row
      mars_ingest_item.mars_ingest_id = id
      mars_ingest_item.save!
    end

    update_columns(item_count: mars_ingest_items.count)
  end

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
