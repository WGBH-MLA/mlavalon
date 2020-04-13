require "open-uri"

class MarsIngest < ActiveRecord::Base
  VALID_FILE_TYPES = %w( csv )

  validate :validate_manifest_url

  def validate_manifest_url
    # manifest_url_present?
    # valid_manifest_url?
    # expected_file_type?
    # valid_manifest_data?
    errors.add(:manifest_url, "#{manifest.errors.messages}") unless manifest.valid?
  end

  private

  def manifest
    @manifest ||= MarsManifest.new(url: manifest_url)
  end


  # guard against nil for the manifest_url before actually calling save on the MarsIngest
  # def manifest_url_present?
  #   unless manifest_url.present?
  #     errors.add(:manifest_url ," is required")
  #     raise ActiveRecord::RecordInvalid.new(self)
  #   end
  # end
  #
  # def expected_file_type?
  #   unless VALID_FILE_TYPES.include?(File.extname(manifest_url).tr('.',''))
  #     errors.add(:manifest_url, " is not an expected file type. Expected extensions are: #{VALID_FILE_TYPES.join(' ')}")
  #   end
  # end
  #
  # def valid_manifest_url?
  #   begin
  #     unless manifest_url_status[0] == "200"
  #       errors.add(:manifest_url, "could not be reached and returns a status code of: #{manifest_url_status.join(', ')}")
  #     end
  #   # rescue but report on the SocketError from open-uri
  #   rescue SocketError => e
  #       errors.add(:manifest_url, "SocketError: failed to open connection to manifest_url")
  #   end
  # end
  #
  # def manifest_url_status
  #   @manifest_url_status ||= open(manifest_url).status
  # end
  #
  # # Not sure if we want to bubble up MarsManifest errors here or if there's a better place.
  # def valid_manifest_data?
  #   manifest = MarsManifest.new(url: manifest_url)
  #   unless manifest.valid?
  #     errors.add(:manifest_url, "#{manifest.errors.messages}")
  #   end
  # end
end
