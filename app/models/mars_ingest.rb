class MarsIngest < ActiveRecord::Base

  VALID_FILE_TYPES = %w( csv )
  VALID_INGEST_FILE_HEADERS = [ "Collection Name", "Collection Description", "Unit Name", "Collection ID", "Title", "Date Issued", "Creators", "Alternative Titles", "Translated Titles", "Uniform Titles", "Statement Of Responsibility", "Date Created", "Copyright Date", "Abstract", "Notes", "Format", "Resource Types", "Contributors", "Publishers", "Genres", "Subjects", "Related Item Urls", "Geographic Subjects", "Temporal Subjects", "Topical Subjects", "Bibliographic Id", "Languages", "Terms Of Use", "Tables Of Contents", "Physical Description", "Other Identifiers", "Comments", "File Label", "File Title", "Instantiation Label", "Instantiation Id", "Instantiation Streaming URL", "Instantiation Duration", "Instantiation Mime Type", "Instantiation Audio Bitrate", "Instantiation Audio Codec", "Instantiation Video Bitrate", "Instantiation Video Codec", "Instantiation Width", "Instantiation HeightFile Location", "File Checksum", "File Size", "File Duration", "File Aspect Ratio", "File Frame Size", "File Format", "File Date Digitized", "File Caption Text", "File Caption Type", "File Other Id", "File Comment" ]

  validate :expected_file_type

  def mars_ingest_errors
    @mars_ingest_errors ||= []
  end

  def expected_file_type
    unless manifest_url.present? && VALID_FILE_TYPES.include?(File.extname(manifest_url).tr('.',''))
      errors.add(:manifest_url, " is not an expected file type. Expected extensions are: #{VALID_FILE_TYPES.join(' ')}")
    end
  end

  def validate_headers
    unexpected_headers = []
    mars_ingest_csv.first.headers.map{ |header| unexpected_headers << header unless VALID_INGEST_FILE_HEADERS.include?(header) }
    mars_ingest_errors << "Unexpected Headers in Manifest: #{unexpected_headers.join(' | ')}" unless unexpected_headers.empty?
  end

  def mars_ingest_csv
    @mars_ingest_csv ||= CSV.new(open(manifest_url), :headers => :first_row)
  end
end
