# MarsManifest is a basic PORO model that uses ActiveModel::Validations to
# encaspsulate validation of the MARS export CSV manifest used as input for the
# Avalon Ingest API. Also provides accessors an enumerable array of
# MarsManifestRow objects, each of which are used to validate individual row
# data.
require 'active_support/core_ext/module/delegation'

class MarsManifest
  include ActiveModel::Validations

  attr_reader :url


  validate :validate_manifest

  delegate :normalize_header, :required_headers, :allowed_headers,
           :validation_methods, :validation_methods_for, to: :class

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
    add_error(:csv, "Data not recognized as CSV.")
    nil
  end

  private

    def validate_manifest
      validate_headers
      validate_rows if errors.empty?
    end

    # Fetches data form the URL in the @url attribute, memoized in @raw_data. If
    # an error occurs, it adds the error message on the :url field, invalidating
    # the model instance.
    # @return String the raw data fetched from the URL in the @url attribute;
    #   nil if an error occurs.
    def raw_data
      # TODO: Stop bypassing SSL check.

      # sub out vertical tabs, they are expected in mars exports
      # grand opening, grand closing
      @raw_data ||= open(url, { encoding: Encoding::UTF_8, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE }).read.gsub(/[\t\v]/, " ").gsub(/\xE2\x80\x98/, %(')).gsub(/\xE2\x80\x99/, %(')).gsub(/\xE2\x80\x9C/, %(")).gsub(/\xE2\x80\x9D/, %("))
      # FM export comes in as UTF-8, but pasting actual curly quotes into a gsub misinterprets the utf-8 byte sequence and spits out 3 invalid characters, crashing the ingest
      # so, explicitly sub out the offending byte sequences themselves to non-hated characters
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
      # ignore blank 'fields' that also have a blank header -> no need to police extra commas at the end of headers or rows
      if headers[col_num].to_s.empty?
        errors.add(:rows, "No header for value '#{value}', column #{col_num + 1}, row #{row_num + 1}.")
      end
    end

    def validate_value_format(value, row_num, col_num)
      validation_methods_for(headers[col_num]).each do |validation_method|
        send(validation_method, value, row_num, col_num)
      end
    end

    def validate_presence(value, row_num, col_num)
      if value.to_s.strip.empty?
        errors.add(:values, "Value required for #{headers[col_num]} in column #{col_num + 1}, row #{row_num + 1}")
      end
    end

    # in order to determine whether a file field's presence is required, we need to verify that there is some sort of data elsewhere in the file field's fileset
    def validate_presence_within_fileset(value, row_num, col_num)
      this_row = rows[row_num]

      found_data_in_this_fileset = false

      # go left
      found_data_in_this_fileset = scan_for_value(this_row, col_num, -1)

      # go right
      found_data_in_this_fileset = scan_for_value(this_row, col_num, 1) unless found_data_in_this_fileset



      if found_data_in_this_fileset
        validate_presence(value, row_num, col_num)
      end
    end

    def scan_for_value(row, index, increment)
      found_data = false
      while !found_data
        # if we START on File Title, we have to exit or else we're going into the next fileset 
        break if MarsManifest.initial_file_header?(headers[index])

        # left or right by 1 cell, depending on value passed in
        index += increment

        # exit if this is not a fileset header, otherwise infinite loop :(
        break unless MarsManifest.instantiation_header?(headers[index]) || MarsManifest.file_header?(headers[index])

        # stop our checking now if we're going to the right -> we hit the next file title
        break if (MarsManifest.initial_file_header?(headers[index]) && increment == 1)

        # record if we found data, which will break while loop
        found_data = row[index].to_s.strip.present?
        break if found_data

        # we need to stop, we're going left and we hit File Title (beginning of fileset)
        break if MarsManifest.initial_file_header?(headers[index]) && increment == -1
      end

      found_data
    end

    def validate_date(value, row_num, col_num)
      unless value =~ /\d{4}-\d{2}-\d{2}/
        errors.add(:values, "Invalid date format for #{headers[col_num]} in column #{col_num + 1}, row #{row_num + 1}, required format is YYYY-MM-DD")
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

    def validate_headers
      # Only validate headers if we have CSV data.
      if csv
        unless missing_headers.empty?
          add_error(:headers, "Missing headers '#{missing_headers.join("','")}'")
        end

        unless unallowed_headers.empty?
          add_error(:headers, "Unallowed headers '#{unallowed_headers.join("', '")}'")
        end
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

    # Checks for unallowed headers from the CSV manifest by normalizing them
    # and then comparing them to the normalized required headers.
    # @return [Array] list of unallowed headers.
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
        # validations.include? :validate_presence
        (validations & [:validate_presence, :validate_presence_within_fileset]).present?

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
        "collection name" => [:validate_presence],
        "collection description" => [],
        "unit name" => [],
        "collection id" => [],
        "title" => [:validate_presence],
        "date issued" => [:validate_date],
        "creator" => [],
        "alternative title" => [],
        "translated title" => [],
        "uniform title" => [],
        "statement of responsibility" => [],
        "date created" => [],
        "copyright date" => [],
        "abstract" => [],

        # "note" => [],
        # "note type" => [],
        "content type" => [],
        "item type" => [],
        "technical notes" => [],

        "format" => [],
        "resource type" => [],
        "contributor" => [],
        "publisher" => [],
        "genre" => [],
        "subject" => [],
        "related item label" => [],
        "related item url" => [],
        "geographic subject" => [],
        "temporal subject" => [],
        "topical subject" => [],
        "bibliographic id" => [],
        "language" => [],
        "terms of use" => [],
        "table of contents" => [],
        "physical description" => [],

        # "other identifier" => [],
        # "other identifier type" => [],
        "mla barcode" => [],

        "comment" => [],
        "file label" => [],
        "file title" => [:validate_presence_within_fileset],
        "instantiation label" => [:validate_presence_within_fileset],
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
        "file comment" => [],
        "file thumbnail offset" => [],
        "file poster offset" => []
      }
    end

    # Normalizes a header string by 1) making lowercase, 2) reducing excessive
    # whitespace down to a single space, 3) stripping leading/trailing
    # whitespace.
    # @return [String] the normalized header.
    def normalize_header(header)
      header.to_s.downcase.gsub(/ +/, ' ').strip
    end

    def collection_header?(header)
      collection_headers.include? normalize_header(header)
    end

    def collection_headers
      [ 'collection name', 'collection description', 'collection id',
        'unit name' ]
    end

    def media_object_header?(header)
      media_object_headers.include? normalize_header(header)
    end

    def media_object_headers
      [ "title", "date issued", "creator", "alternative title", "translated
        title", "uniform title", "statement of responsibility", "date created",
        "copyright date", "abstract", "note", "note type", "format", "resource
        type", "contributor", "publisher", "genre", "subject", "related item
        label", "related item url", "geographic subject", "temporal subject",
        "topical subject", "bibliographic id", "language", "terms of use",
        "table of contents", "physical description", "other identifier", "other
        identifier type", "comment", "thumbnail offset", "poster offset" ]
    end

    def notes_header?(header)
      notes_headers.include? normalize_header(header)
    end

    def notes_headers
      [ "content type", "item type", "technical notes" ]
    end

    def other_id_header?(header)
      other_id_headers.include? normalize_header(header)
    end

    def other_id_headers
      [ "mla barcode" ]
    end

    def file_header?(header)
      file_headers.include? normalize_header(header)
    end

    def file_headers
      [ "file label", "file title", "file location", "file checksum",
        "file size", "file duration", "file aspect ratio", "file frame size",
        "file format", "file date digitized", "file caption text",
        "file caption type", "file other id", "file comment", "file thumbnail offset", "file poster offset" ]
    end

    def initial_file_header?(header)
      normalize_header(header) == 'file title'
    end

    # def initial_file_headers
    #   ['file label', 'file title']
    # end

    def instantiation_header?(header)
      instantiation_headers.include? normalize_header(header)
    end

    def instantiation_headers
      [ "instantiation duration", "instantiation mime type",
        "instantiation audio bitrate", "instantiation audio codec",
        "instantiation video bitrate", "instantiation video codec",
        "instantiation width", "instantiation height", "instantiation label",
        "instantiation id", "instantiation streaming url" ]
    end

    def multivalued?(header)
      multivalued_headers.include? normalize_header(header)
    end

    def multivalued_headers
      [ 'creator', 'alternative title', 'translated title', 'uniform title',
        'note', 'note type', 'resource type', 'contributor', 'publisher',
        'genre', 'subject', 'related item label', 'related item url',
        'geographic subject', 'temporal subject', 'topical subject', 'language',
        'table of contents', 'other identifier type', 'other identifier',
        'comment' ]
    end

  end # end class << self
end
