require 'json'
require 'uri'

class MarsIngestItem < ActiveRecord::Base
  # belongs_to :mars_ingest

  # csv row objec
  attr_accessor :csv_header_array
  attr_accessor :csv_value_array

  before_save :create_payload
  def create_payload
    if csv_header_array && csv_value_array
      self.row_payload = create_row_hash.to_json
    end
  end

  # validates do
  #   # runs the marsingestrow validations
  # end

  # validates :mars_ingest_id, presence: true
  validates :row_payload, presence: true
  validates :status, inclusion: %w(enqueued processing failed succeeded)
  validate :valid_json_parse

  # validates_with MarsManifestRowVali

  def valid_json_parse
    return unless row_payload
    JSON.parse(row_payload)
  rescue JSON::ParserError => e
    errors.add(:base, "Failed to parse payload: #{e.message}")
  end

  def is_collection_field?(field_name)
    MARS_INGEST_API_SCHEMA[field_name].type == :collection
  end

  def is_single_field?(field_name)
    # ['Creators','Alternative Titles','Translated Titles','Uniform Titles','Notes','Resource Types','Contributors','Publishers','Genres','Subjects','Related Item Urls','Geographic Subjects','Temporal Subjects','Topical Subjects','Languages','Tables Of Contents','Other Identifiers','Comments'].include?(field_name)
    MARS_INGEST_API_SCHEMA[field_name].type == :media_object
  end

  def is_multi_field?(field_name)
    # ['Creators','Alternative Titles','Translated Titles','Uniform Titles','Notes','Resource Types','Contributors','Publishers','Genres','Subjects','Related Item Urls','Geographic Subjects','Temporal Subjects','Topical Subjects','Languages','Tables Of Contents','Other Identifiers','Comments'].include?(field_name)
    MARS_INGEST_API_SCHEMA[field_name].type == :media_object_multi
  end

  def is_instantiation_field?(field_name)
    # ['Instantiation Label','Instantiation Id','Instantiation Streaming URL','Instantiation Streaming URL','Instantiation Duration','Instantiation Mime Type','Instantiation Audio Bitrate','Instantiation Audio Codec','Instantiation Video Bitrate','Instantiation Video Codec','Instantiation Width','Instantiation Height'].include?(field_name)
    MARS_INGEST_API_SCHEMA[field_name].type == :instantiation
  end

  def is_file_field?(field_name)
    
    MARS_INGEST_API_SCHEMA[field_name].type == :file
  end

  def find_fileset_indexes(fileset_start_name)
    csv_header_array.each_with_index.map {|f,i| i if f == fileset_start_name}.compact
  end

  def pull_filesets(indexes)
    filesets = []
    # indexes is array of filesetstart indexes
    indexes.each_with_index do |start_of_fileset, index|

      fileset = { files: [{}] }

      # cut out section for this fileset
      start_of_next_fileset = indexes[index + 1] || -1

      fileset_headers = csv_header_array.slice!(start_of_fileset..start_of_next_fileset)
      fileset_values = csv_value_array.slice!(start_of_fileset..start_of_next_fileset)

      # make this set into a hash
      fileset_headers.each_with_index do |header, i|
        ingest_api_header = convert_header(header)

        if is_instantiation_field?(header)
          # its an Instantiation field
          fileset[:files].first[ingest_api_header] = fileset_values[i]
        else
          # its a File field
          fileset[ingest_api_header] = fileset_values[i]
        end
      end

      # add each fileset to this fookin array
      filesets << fileset
    end

    filesets
  end

  # convert input header to ingest key name
  def convert_header(input_header)
    MARS_INGEST_API_SCHEMA[input_header].ingest_field_name
  end

  def create_row_hash
    row_hash = {}
    row_hash[:fields] = {}

    collection_id = nil
    collection_name = nil
    collection_id = nil
    collection_desc = nil
    unit_name = nil

    indexes = find_fileset_indexes('File Label')
    # this takes filesets OUT of values AND headers arrays
    filesets = pull_filesets(indexes)
    row_hash[:files] = filesets

    csv_header_array.each_with_index do |header, index|
      ingest_api_header = convert_header(header)
      next unless ingest_api_header

      if is_multi_field?(header)

        # init array if missing
        row_hash[:fields][ingest_api_header] ||= []

        # shovel this
        row_hash[:fields][ingest_api_header] << csv_value_array[index]
      elsif is_single_field?(header)
        
        row_hash[:fields][ingest_api_header] = csv_value_array[index]
      elsif is_collection_field?(header)

        # collect all this junk in case we're creating the collection
        if header == 'Collection Name'
          collection_name = csv_value_array[index]
        elsif header == 'Collection ID'
          collection_id = csv_value_array[index]
        elsif header == 'Collection Description'
          collection_desc = csv_value_array[index]
        elsif header == 'Unit Name'
          unit_name = csv_value_array[index]
        end
      end
    end

    # hardcoded for the API
    row_hash[:workflow_name] = "avalon"
    row_hash[:percent_complete] = "100.0"
    row_hash[:percent_succeeded] = "100.0"
    row_hash[:percent_failed] = "0"
    row_hash[:status_code] = "COMPLETED"


    row_hash[:collection_id] = collection_id || CollectionCreator.find_or_create_collection(collection_name, unit_name, collection_desc).id

    row_hash
  end

  MARS_INGEST_API_SCHEMA = {
    # gotta look up the damn id
    'Collection ID' => MarsIngestFieldDef.new(:collection, false),
    'Collection Name' => MarsIngestFieldDef.new(:collection, false),
    'Collection Description' => MarsIngestFieldDef.new(:collection, false),
    'Unit Name' => MarsIngestFieldDef.new(:collection, false),

    'Title' => MarsIngestFieldDef.new(:media_object, :title),
    'Date Issued' => MarsIngestFieldDef.new(:media_object, :date_issued),
    'Statement Of' => MarsIngestFieldDef.new(:media_object, :statement_of_responsibility),
    'Date Created' => MarsIngestFieldDef.new(:media_object, :date_created),
    'Copyright Date' => MarsIngestFieldDef.new(:media_object, :copyright_date),
    'Abstract' => MarsIngestFieldDef.new(:media_object, :abstract),
    'Format' => MarsIngestFieldDef.new(:media_object, :format),
    'Bibliographic Id' => MarsIngestFieldDef.new(:media_object, :bibliographic_id),
    'Terms Of Use' => MarsIngestFieldDef.new(:media_object, :terms_of_use),
    'Physical Description' => MarsIngestFieldDef.new(:media_object, :physical_description),
    'Statement Of Responsibility' => MarsIngestFieldDef.new(:media_object, :statement_of_responsibility),

    'Creators' => MarsIngestFieldDef.new(:media_object_multi, :creator),
    'Alternative Titles' => MarsIngestFieldDef.new(:media_object_multi, :alternative_title),
    'Translated Titles' => MarsIngestFieldDef.new(:media_object_multi, :translated_title),
    'Uniform Titles' => MarsIngestFieldDef.new(:media_object_multi, :uniform_title),
    'Notes' => MarsIngestFieldDef.new(:media_object_multi, :note),
    'Resource Types' => MarsIngestFieldDef.new(:media_object_multi, :resource_type),
    'Contributors' => MarsIngestFieldDef.new(:media_object_multi, :contributor),
    'Publishers' => MarsIngestFieldDef.new(:media_object_multi, :publisher),
    'Genres' => MarsIngestFieldDef.new(:media_object_multi, :genre),
    'Subjects' => MarsIngestFieldDef.new(:media_object_multi, :subject),
    'Related Item Urls' => MarsIngestFieldDef.new(:media_object_multi, :related_item_url),
    'Geographic Subjects' => MarsIngestFieldDef.new(:media_object_multi, :geographic_subject),
    'Temporal Subjects' => MarsIngestFieldDef.new(:media_object_multi, :temporal_subject),
    'Topical Subjects' => MarsIngestFieldDef.new(:media_object_multi, :topical_subject),
    'Languages' => MarsIngestFieldDef.new(:media_object_multi, :language),
    'Tables Of Contents' => MarsIngestFieldDef.new(:media_object_multi, :table_of_contents),
    'Other Identifiers' => MarsIngestFieldDef.new(:media_object_multi, :other_identifier),
    'Comments' => MarsIngestFieldDef.new(:media_object_multi, :comment),

    'Instantiation Label' => MarsIngestFieldDef.new(:instantiation, :label),
    'Instantiation Id' => MarsIngestFieldDef.new(:instantiation, :id),
    'Instantiation Streaming URL' => MarsIngestFieldDef.new(:instantiation, :url),
    'Instantiation Streaming URL' => MarsIngestFieldDef.new(:instantiation, :hls_url),
    'Instantiation Duration' => MarsIngestFieldDef.new(:instantiation, :duration),
    'Instantiation Mime Type' => MarsIngestFieldDef.new(:instantiation, :mime_type),
    'Instantiation Audio Bitrate' => MarsIngestFieldDef.new(:instantiation, :audio_bitrate),
    'Instantiation Audio Codec' => MarsIngestFieldDef.new(:instantiation, :audio_codec),
    'Instantiation Video Bitrate' => MarsIngestFieldDef.new(:instantiation, :video_bitrate),
    'Instantiation Video Codec' => MarsIngestFieldDef.new(:instantiation, :video_codec),
    'Instantiation Width' => MarsIngestFieldDef.new(:instantiation, :width),
    'Instantiation Height' => MarsIngestFieldDef.new(:instantiation, :height),

    'File Label' => MarsIngestFieldDef.new(:file, :label),
    'File Title' => MarsIngestFieldDef.new(:file, :title),
    'File Location' => MarsIngestFieldDef.new(:file, :file_location),
    'File Checksum' => MarsIngestFieldDef.new(:file, :file_checksum),
    'File Size' => MarsIngestFieldDef.new(:file, :file_size),
    'File Duration' => MarsIngestFieldDef.new(:file, :duration),
    'File Aspect Ratio' => MarsIngestFieldDef.new(:file, :display_aspect_ratio),
    'File Frame Size' => MarsIngestFieldDef.new(:file, :original_frame_size),
    'File Format' => MarsIngestFieldDef.new(:file, :file_format),
    'File Caption Text' => MarsIngestFieldDef.new(:file, :captions),
    'File Caption Type' => MarsIngestFieldDef.new(:file, :captions_type),
    'File Other Id' => MarsIngestFieldDef.new(:file, :other_identifier),
    'File Comment' => MarsIngestFieldDef.new(:file, :comment),
    'File Date Digitized' => MarsIngestFieldDef.new(:file, :date_digitized)
  }
end
