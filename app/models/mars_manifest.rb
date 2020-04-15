# MarsManifest is a basic PORO model that uses ActiveModel::Validations to
# encaspsulate validation of the MARS export CSV manifest used as input for the
# Avalon Ingest API. Also provides accessors an enumerable array of
# MarsManifestRow objects, each of which are used to validate individual row
# data.
require 'active_support/core_ext/module/delegation'

class MarsManifest
  include ActiveModel::Validations

  attr_reader :url

<<<<<<< HEAD
  validate :validate_manifest
  # validate :validate_headers
  # validate :validate_rows

  delegate :normalize_header, :required_headers, :allowed_headers,
           :validation_methods, :validation_methods_for, to: :class
=======
  validate :valid_headers?
>>>>>>> WIP

  def initialize(url:)
    @url = url
  end

  def headers
    @headers ||= Array(csv&.first)
  end

  def rows
    @rows ||= Array(csv&.slice(1..-1))
  end

  # Parses raw data as CSV, memoized in @csv. If an error occurs, it adds
  # the error message on the :csv field, invalidating the model instance.
  # @return Array parsed CSV data; nil if an error occcurs.
  def csv
    @csv ||= CSV.parse(raw_data)
  rescue => e
    add_error(:csv, e.message)
    nil
  end

  private

    def validate_manifest
      validate_headers
      validate_rows if errors.empty?
    end

    # def mars_manifest_rows
    #   @mars_manifest_rows ||= rows.map do |row_vals|
    #     MarsManifestRow.new(headers: headers, values: row_vals)
    #   end
    # end

    # Fetches data form the URL in the @url attribute, memoized in @raw_data. If
    # an error occurs, it adds the error message on the :url field, invalidating
    # the model instance.
    # @return String the raw data fetched from the URL in the @url attribute;
    #   nil if an error occurs.
    def raw_data
      @raw_data ||= Net::HTTP.get(URI.parse(url))
    rescue => e
      add_error(:url, "Invalid Manifest URL: '#{url}'")
    end

    def validate_rows
      rows.each_with_index { |row, row_num| validate_row(row, row_num) }
    end

    def validate_row(row, row_num)
      row.each_with_index do |value, col_num|
        validate_value_has_header(value, row_num, col_num)
        validate_value_format(value, row_num, col_num)
      end
    end

    def validate_value_has_header(value, row_num, col_num)
      if headers[col_num].to_s.empty?
        errors.add(:rows, "No header for value '#{value}', column #{col_num + 1}, row #{row_num + 1}.")
      end
    end

    def validate_value_format(value, row_num, col_num)
      validation_methods_for(headers[col_num]).each do |validation_method|
        send(validation_method, value, row_num, col_num)
      end
    end

    def presence(value, row_num, col_num)
      if value.to_s.strip.empty?
        errors.add(:values, "Value required for #{headers[col_num]} in column #{col_num}, row #{row_num}")
      end
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
<<<<<<< HEAD
    def validate_headers
      if csv
        unless missing_headers.empty?
          add_error(:headers, "Missing headers '#{missing_headers.join("','")}'")
        end

        unless unallowed_headers.empty?
          add_error(:headers, "Unallowed headers '#{unallowed_headers.join("', '")}'")
        end
=======
    def valid_headers?
<<<<<<< HEAD
      # If we're already invalid, don't try to validate more.
      return unless errors.empty?

      if missing_headers?
        add_error(:headers, "Missing headers '#{missing_headers.join("','")}'")
      end

      if unrecognized_headers?
        add_error(:headers, "Unrecognized headers '#{unrecognized_headers.join("', '")}'")
>>>>>>> Renders modal form for creating new MarsIngest
=======
      # Only validate headers if we have CSV data.
      if csv
        if missing_headers?
          add_error(:headers, "Missing headers '#{missing_headers.join("','")}'")
        end

        if unrecognized_headers?
          add_error(:headers, "Unrecognized headers '#{unrecognized_headers.join("', '")}'")
        end
>>>>>>> WIP
      end
    end

    # Checks for missing headers from the CSV manifest by normalizing them and
    # then comparing them to the normalized required headers.
    # @return [Array] list of missing headers.
    def missing_headers
      @missing_headers ||= MarsManifest.required_headers.select do |required_header|
        normalized_headers.exclude? required_header
      end
    end

    # Checks for unrecognized headers from the CSV manifest by normalizing them
    # and then comparing them to the normalized required headers.
    # @return [Array] list of unrecognized headers.
    def unallowed_headers
      @unallowed_headers ||= headers.select do |header|
        allowed_headers.exclude? normalize_header(header)
      end
    end

    def normalized_headers
      @normalized_headers ||= headers.map { |h| normalize_header(h) }
    end

  # MarsManfiest class methods
  class << self
    def required_headers
      validation_methods.select do |field, validations|
        validations.include? :presence
      end.keys
    end

    def allowed_headers
      validation_methods.keys
    end

    def validation_methods_for(header)
      validation_methods[normalize_header(header)] || []
    end

    def validation_methods
      {
        "collection name" => [:presence],
        "collection description" => [],
        "unit name" => [],
        "collection id" => [],
        "title" => [],
        "date issued" => [],
        "creator" => [],
        "alternative title" => [],
        "translated title" => [],
        "uniform title" => [],
        "statement of responsibility" => [],
        "date created" => [],
        "copyright date" => [],
        "abstract" => [],
        "note" => [],
        "format" => [],
        "resource type" => [],
        "contributor" => [],
        "publisher" => [],
        "genre" => [],
        "subject" => [],
        "related item url" => [],
        "geographic subject" => [],
        "temporal subject" => [],
        "topical subject" => [],
        "bibliographic id" => [],
        "language" => [],
        "terms of use" => [],
        "tables of content" => [],
        "physical description" => [],
        "other identifier" => [],
        "other identifier type" => [],
        "comment" => [],
        "file label" => [],
        "file title" => [],
        "instantiation label" => [],
        "instantiation id" => [],
        "instantiation streaming url" => [],
        "instantiation duration" => [],
        "instantiation mime type" => [],
        "instantiation audio bitrate" => [],
        "instantiation audio codec" => [],
        "instantiation video bitrate" => [],
        "instantiation video codec" => [],
        "instantiation width" => [],
        "instantiation height" => [],
        "file location" => [],
        "file checksum" => [],
        "file size" => [],
        "file duration" => [],
        "file aspect ratio" => [],
        "file frame size" => [],
        "file format" => [],
        "file date digitized" => [],
        "file caption text" => [],
        "file caption type" => [],
        "file other id" => [],
        "file comment" => []
      }
    end

    # Normalizes a header string by 1) making lowercase, 2) reducing excessive
    # whitespace down to a single space, 3) stripping leading/trailing
    # whitespace.
    # @return [String] the normalized header.
    def normalize_header(header)
      header.to_s.downcase.gsub(/ +/, ' ').strip
    end
  end
end
