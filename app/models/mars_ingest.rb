class MarsIngest < ActiveRecord::Base
  validate :validate_manifest

  def validate_manifest
    unless manifest.valid?
      manifest.errors.each do |_field, msgs|
        errors.add(:manifest, msgs)
      end
    end
  end

  def start
    headers = @manifest.headers

    @manifest.rows.each_with_index do |row, index|
      next if index == 0
      mars_item = MarsIngestItem.new(status: 'enqueued')
      mars_item.csv_header_array = headers
      mars_item.csv_value_array = row
      mars_item.save!
      job_id = MarsIngestItemJob.new(mars_item.id).perform_later
      Rails.logger.info("Started MarsIngestItemJob with jid #{job_id} from MarsIngestItem #{mars_item.id}")
    end
  end

  private

    def manifest
      @manifest ||= MarsManifest.new(url: manifest_url)
    end
end
