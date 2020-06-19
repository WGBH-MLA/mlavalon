class MarsIngest < ActiveRecord::Base
  belongs_to :submitter, class_name: 'User'
  has_many :mars_ingest_items, -> { order('id ASC') }

  after_create do
    manifest.rows.each do |row|
      payload = ManifestToPayloadMapper.new(manifest.headers, row, submitter.user_key).payload
      mars_ingest_item = MarsIngestItem.new(row_payload: payload)
      mars_ingest_item.mars_ingest_id = id
      mars_ingest_item.save!
    end

    update_columns(item_count: mars_ingest_items.count)
  end

  validates :manifest_url, presence: true
  validate :validate_manifest

  def manifest
    @manifest ||= MarsManifest.new(url: manifest_url)
  end

  private

    def validate_manifest
      unless manifest.valid?
        manifest.errors.each do |_field, msgs|
          errors.add(:manifest, msgs)
        end
      end
    end
end
