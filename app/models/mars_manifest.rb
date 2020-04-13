# MarsManifest is a basic PORO model that uses ActiveModel::Validations to
# encaspsulate validation of the MARS export CSV manifest used as input for the
# Avalon Ingest API. Also provides accessors an enumerable array of
# MarsManifestRow objects, each of which are used to validate individual row
# data.
class MarsManifest
  include ActiveModel::Validations

  attr_reader :url

  validates :rows, presence: true
  validates :headers, presence: true
  validate :valid_headers?

  def initialize(url:)
    @url = url
  end

  def headers
    @headers ||= Array(csv.first) if csv
  end

  def rows
    @rows ||= csv&.map do |row|
      # TODO: code it
      # MarsManifestRow.new(headers: headers, row_data: row)
    end
  end

  private

    # Parses raw data as CSV, memoized in @csv. If an error occurs, it adds
    # the error message on the :csv field, invalidating the model instance.
    # @return Array parsed CSV data; nil if an error occcurs.
    def csv
      @csv ||= CSV.parse(raw_data) if raw_data
    rescue => e
      add_error(:csv, e.message)
    end

    # Fetches data form the URL in the @url attribute, memoized in @raw_data. If
    # an error occurs, it adds the error message on the :url field, invalidating
    # the model instance.
    # @return String the raw data fetched from the URL in the @url attribute;
    #   nil if an error occurs.
    def raw_data
      @raw_data ||= Net::HTTP.get(URI.parse(url))
    rescue => e
      add_error(:url, e.message)
    end

    # Runs validation on each row.
    # @return [Boolean] true if all rows are valid.
    def rows_valid?
      return true
      # TODO: replace true with validation of all rows, e.g...
      # rows.map { |row| row.valid? }.all?
    end

    # Adds an error message to a field idempotently (because errors.add is not
    # idempotent, and you can end up with a field having duplicate errors).
    # @param field [Symbol] the field name.
    # @param msg [String] the error message
    # @return [nil] always
    def add_error(field, msg)
      errors.add(field, msg) unless errors[field].include? msg
      nil
    end

    # @return [Boolean] true if #headers are valid; false if not.
    def valid_headers?
      # If we're already invalid, don't try to validate more.
      return unless errors.empty?

      if missing_headers?
        add_error(:headers, "Missing headers '#{missing_headers.join("','")}'")
      end

      if unrecognized_headers?
        add_error(:headers, "Unrecognized headers '#{unrecognized_headers.join("', '")}'")
      end
    end

    # Checks for missing headers from the CSV manifest by normalizing them and
    # then comparing them to the normalized required headers.
    # @return [Array] list of missing headers.
    def missing_headers
      normalized_headers = headers.map { |h| normalize_header(h) }
      @missing_headers ||= MarsManifest.required_headers.select do |req_header|
        normalized_headers.exclude? normalize_header(req_header)
      end
    end

    # Checks for unrecognized headers from the CSV manifest by normalizing them
    # and then comparing them to the normalized required headers.
    # @return [Array] list of unrecognized headers.
    def unrecognized_headers
      normalized_required_headers = MarsManifest.required_headers.map { |h| normalize_header(h) }
      @unrecognized_headers ||= headers.select do |header|
        normalized_required_headers.exclude? normalize_header(header)
      end
    end

    # @return [Boolean] true if there are missing headers; false if not.
    def missing_headers?; !missing_headers.empty?; end

    # @return [Boolean] true if there are unercognized headers; false if not.
    def unrecognized_headers?; !unrecognized_headers.empty?; end

    # Normalizes a header string by 1) making lowercase, 2) reducing excessive
    # whitespace down to a single space, 3) stripping leading/trailing
    # whitespace.
    # @return [String] the normalized header.
    def normalize_header(header)
      header.downcase.gsub(/ +/, ' ').strip
    end

  # MarsManfiest class methods
  class << self
    def required_headers
      [
        "Collection Name",
        "Collection Description",
        "Unit Name",
        "Collection ID",
        "Title",
        "Date Issued",
        "Creators",
        "Alternative Titles",
        "Translated Titles",
        "Uniform Titles",
        "Statement Of Responsibility",
        "Date Created",
        "Copyright Date",
        "Abstract",
        "Notes",
        "Format",
        "Resource Types",
        "Contributors",
        "Publishers",
        "Genres",
        "Subjects",
        "Related Item Urls",
        "Geographic Subjects",
        "Temporal Subjects",
        "Topical Subjects",
        "Bibliographic Id",
        "Languages",
        "Terms Of Use",
        "Tables Of Contents",
        "Physical Description",
        "Other Identifiers",
        "Comments",
        "File Label",
        "File Title",
        "Instantiation Label",
        "Instantiation Id",
        "Instantiation Streaming URL",
        "Instantiation Duration",
        "Instantiation Mime Type",
        "Instantiation Audio Bitrate",
        "Instantiation Audio Codec",
        "Instantiation Video Bitrate",
        "Instantiation Video Codec",
        "Instantiation Width",
        "Instantiation Height",
        "File Location",
        "File Checksum",
        "File Size",
        "File Duration",
        "File Aspect Ratio",
        "File Frame Size",
        "File Format",
        "File Date Digitized",
        "File Caption Text",
        "File Caption Type",
        "File Other Id",
        "File Comment"
      ]
    end
  end
end
