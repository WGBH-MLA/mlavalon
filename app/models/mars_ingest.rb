class MarsIngest < ActiveRecord::Base
  belongs_to :submitter, class_name: 'User'
  has_many :mars_ingest_items, -> { order('id ASC') }

  after_create do
    manifest.rows.each do |row|
      payload = ManifestToPayloadMapper.new(manifest.headers, row, submitter.user_key).payload
      media_pim_id = extract_media_pim_id(payload)
      mars_ingest_item = MarsIngestItem.new(row_payload: payload, media_pim_id: media_pim_id)
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

  def in_progress?
    mars_ingest_items.present? && mars_ingest_items.any? { |mii| ['succeeded', 'failed'].exclude?(mii.status) }
  end

  def extract_media_pim_id(payload)
    # these are paired together in order, cause thats what the ingest API desires
    raise "Did not receive Media PIM ID for record! #{payload.inspect}" unless payload['fields']['other_identifier_type']
    index = payload['fields']['other_identifier_type'].index('media pim id')
    payload['fields']['other_identifier'][index] if index
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
