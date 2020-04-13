# MarsManifest is a basic PORO model that uses ActiveModel::Validations to
# encaspsulate validation of the MARS export CSV manifest used as input for the
# Avalon Ingest API. Also provides accessors an enumerable array of
# MarsManifestRow objects, each of which are used to validate individual row
# data.
require 'active_support/core_ext/module/delegation'

class MarsManifest
  include ActiveModel::Validations

  attr_reader :url

  validates :headers, presence: true
  # validate :validate_headers
  validate :validate_rows

  delegate :normalize_header, :validators_for, to: :class

  def initialize(url:)
    @url = url
  end

  def headers
    @headers ||= Array(csv&.first)
  end

  def rows
    # Get all rows after the header.
    @rows ||= csv&.slice(1..-1)
  end

  private

    # Parses raw data as CSV, memoized in @csv. If an error occurs, it adds
    # the error message on the :csv field, invalidating the model instance.
    # @return Array parsed CSV data; nil if an error occcurs.
    def csv
      @csv ||= CSV.parse(raw_data)
    rescue => e
      add_error(:csv, e.message)
      nil
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
      nil
    end

    # Runs validation on each row.
    # @return [Boolean] true if all rows are valid.
    def validate_rows
      return true
      # TODO: replace true with validation of all rows, e.g...
      # rows.map { |row| row.valid? }.all?
    end

    # Adds an error message to a field idempotently (because errors.add is not
    # idempotent, and you can end up with a field having duplicate errors).
    # @param field [Symbol] the field name.
    # @param msg [String] the error message
    def add_error(field, msg)
      errors.add(field, msg) unless errors[field].include? msg
    end

    # @return [Boolean] true if #headers are valid; false if not.
    def validate_headers
      unless missing_headers.empty?
        add_error(:headers, "Missing headers '#{missing_headers.join("','")}'")
      end

      unless unrecognized_headers.empty?
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

    def validate_rows
      rows.each_with_index { |row_vals, i| validate_row(row_vals: row_vals, row_num: i + 1) }
    end

    def validate_row_vals(row_val:, row_num:)
      row_vals.each_with_index do |val, i|
        validate_cell(value: val, header: headers[col_num], row_num: row_num)
      end
    end

    def validate_cell(value:, header:, row_num:)
      validators_for(header).each do |validator|
        unless validator.valid?(val)
          add_error(header, "Invalid value #{val} for #{header} on row #{row_num}")
        end
      end
    end

  # MarsManfiest class methods
  class << self
    def required_headers
      allowed_headers
    end

    def allowed_headers
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
        "Instantiation HeightFile Location",
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

    # Normalizes a header string by 1) making lowercase, 2) reducing excessive
    # whitespace down to a single space, 3) stripping leading/trailing
    # whitespace.
    # @return [String] the normalized header.
    def normalize_header(header)
      header.downcase.gsub(/ +/, ' ').strip
    end
  end
end
