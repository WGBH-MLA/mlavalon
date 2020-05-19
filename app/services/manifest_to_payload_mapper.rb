class ManifestToPayloadMapper
  Field = Struct.new(:header, :value)

  delegate :collection_header?, :media_object_header?, :notes_header?, :file_header?,
    :initial_file_header?, :instantiation_header?, :normalize_header,
    :multivalued?, to: MarsManifest

  delegate :api_field_name_for, to: :class

  attr_reader :headers, :row_data, :submitter_user_key

  def initialize(headers, row_data, submitter_user_key)
    @headers = headers
    @row_data = row_data
    # needed for creating a new collection if necessary
    @submitter_user_key = submitter_user_key
  end

  def payload
    @payload ||= {}.tap do |p|
      p['collection_id'] = collection.id
      p['fields'] = media_object_hash
      p['fields'].merge!( notes_hash )
      p['fields'].merge!( other_id_hash )
      p['files'] = file_hashes
    end

    # @payload = compact_payload(@payload)
    pl = @payload.clone
    @payload = compact_hash(pl)
  end

  # def compact_payload(payload)
  #   # cleaning up the mess
  #   clean_payload = payload.clone
  #   clean_payload['files'] = compact_filearray(payload['files'])
  #   clean_payload['fields'] = compact_key(payload['fields'])
  #   clean_payload
  # end

  # def compact_filearray(filearray)
  #   filearray.map do |file|

  #     # compact the inner files
  #     newfilefiles = file['files'].map { |ff| compact_key(ff) }
  #     # compact the outer files
  #     newfile = compact_key(file)
  #     # reassign the inner files
  #     newfile['files'] = newfilefiles

  #     newfile
  #   end
  # end

  # def compact_key(hash)
  #   hash.delete_if {|header, value| value == "" || value.nil? || (value.is_a?(Array) && value.all? {|v| v.nil? || v == "" })  }
  # end

  def compact_hash(hash)
    newhash = {}
    hash.each do |k,v|

      if v.is_a?(Array)

        # if its an array of nils or ""s, don't pass this key on at all
        unless v.all? {|element| element == "" || element.nil?}

          # if array of hashes, do it again for next layer
          if v.all? {|element| element.is_a?(Hash) }

            newhash[k] = v.map {|h| compact_hash(h) }
          else

            # its a multivalued field, pass on the actual values in this array
            newhash[k] = v.reject { |value| value == "" || value.nil? }
          end

        end
      elsif v.is_a?(String)

        # its a single value field, only pass key through if value
        newhash[k] = v unless v == "" || v.nil?
      elsif v.is_a?(Hash)

        # this key is a hash do it again for this layer
        newhash[k] = compact_hash(v)
      end

    end

    newhash
  end


  private

    # Returns a found (or new) collection based on the collection fields and
    # the submitter's email.
    def collection
      @collection ||= CollectionCreator.find_or_create_collection(
        collection_hash['collection name'],
        collection_hash['unit name'],
        collection_hash['collection description'],
        submitter_user_key
      )
    end

    # Converts collection fields into a hash.
    # Similar to fields_to_hash, but collection fields do not have
    # corresponding api field names, nor are any of them multivalued.
    def collection_hash
      collection_field_pairs = collection_fields.map do |field|
        [ normalize_header(field.header), field.value ]
      end
      Hash[ collection_field_pairs ]
    end


    # Combines headers/value pairs into a single struct for easier handling.
    def fields
      @fields = headers.map.with_index do |header, index|
        Field.new(header, row_data[index])
      end
    end

    # Selects collection fields.
    def collection_fields
      fields.select { |field| collection_header?(field.header) }
    end

    # Converts media object fields into a hash.
    def media_object_hash
      fields_to_hash media_object_fields
    end

    # Selects media object fields.
    def media_object_fields
      fields.select { |field| media_object_header?(field.header) }
    end

    def other_id_fields
      fields.select {|field| other_id_header?(field.header)}
    end

    def other_id_hash
      other_id = {
        'other_identifier_type' => [],
        'other_identifier' => []
      }

      other_id_fields.each do |other_id|
        other_id['other_identifier_type'] << api_field_name_for(other_id.header)
        other_id['other_identifier'] << other_id.value
      end

      other_id
    end

    def notes_fields
      fields.select {|field| notes_header?(field.header)}
    end

    def notes_hash
      notes = {
        'note_type' => [],
        'note' => []
      }

      notes_fields.each do |note|
        notes['note_type'] << api_field_name_for(note.header)
        notes['note'] << note.value
      end

      notes
    end

    # Converts files/instantiation fields into hashes.
    def file_hashes
      @file_hashes ||= file_field_sets.map do |file_field_set|
        instantiation_fields, file_fields = file_field_set.partition do |field|
          instantiation_header?(field.header)
        end

        file_hash = fields_to_hash(file_fields)
        file_hash['files'] = [fields_to_hash(instantiation_fields)]

        file_hash
      end
    end

    # Returns an array of arrays: groups of file/instantiation fields.
    def file_field_sets
      @file_field_sets ||= begin
        # Select only file and instantiation fields.
        file_and_instantiation_fields = fields.select { |field| file_header?(field.header) || instantiation_header?(field.header) }

        # Slice the selected fields into field sets for each file.
        file_and_instantiation_fields.slice_when do |prev_field, field|
          initial_file_header?(field.header) && !initial_file_header?(prev_field.header)
        end
      end
    end

    # Converts these fields into a hash for the payload.
    def fields_to_hash(these_fields)
      combined_fields = combine_multivalued_fields(these_fields)
      combined_pairs = combined_fields.map do |field|

        # does the normalize_ case ever happen?
        key = api_field_name_for(field.header) || normalize_header(field.header)
        [ key, encode_values(field.value) ]
      end
      Hash[ combined_pairs ]
    end

    def encode_values(val)
      if val.is_a?(String)
        encode_value(val)
      elsif val.is_a?(Array)
        val.map {|v| encode_value(v) }
      end
    end

    def encode_value(val)
      val.to_s.force_encoding('UTF-8')
    end

    # Checks for multivalued fields, turns them into arrays, and combines
    # all the values for the repeatable header.
    def combine_multivalued_fields(uncombined_fields)
      combined_fields = {}
      uncombined_fields.each do |field|
        normalized_header = normalize_header(field.header)
        if multivalued?(normalized_header)
          combined_fields[normalized_header] ||= Field.new(field.header, [])
          combined_fields[normalized_header].value << field.value
        else
          combined_fields[normalized_header] ||= Field.new(field.header, field.value)
        end
      end
      combined_fields.values
    end

  class << self
    delegate :normalize_header, to: MarsManifest

    def api_field_name_for(header)
      map = {
        'collection id' => 'collection_id',
        'title' => 'title',
        'date issued' => 'date_issued',
        'statement of' => 'statement_of_responsibility',
        'date created' => 'date_created',
        'copyright date' => 'copyright_date',
        'abstract' => 'abstract',
        'format' => 'format',
        'bibliographic id' => 'bibliographic_id',
        'terms of use' => 'terms_of_use',
        'physical description' => 'physical_description',
        'statement of responsibility' => 'statement_of_responsibility',
        'creator' => 'creator',
        'alternative title' => 'alternative_title',
        'translated title' => 'translated_title',
        'uniform title' => 'uniform_title',

        # 'note' => 'note',
        # 'note type' => 'note_type',
        # not real API field names, these are values for note_type
        'content type' => 'content_type',
        'item type' => 'item_type',
        'technical notes' => 'technical',

        'resource type' => 'resource_type',
        'contributor' => 'contributor',
        'publisher' => 'publisher',
        'genre' => 'genre',
        'subject' => 'subject',
        'related item label' => 'related_item_label',
        'related item url' => 'related_item_url',
        'geographic subject' => 'geographic_subject',
        'temporal subject' => 'temporal_subject',
        'topical subject' => 'topical_subject',
        'language' => 'language',
        'table of contents' => 'table_of_contents',
        
        # 'other identifier type' => 'other_identifier_type',
        # 'other identifier' => 'other_identifier',
        # not real API field names, these are values for other_identifier_type        
        'mla barcode' => 'videorecording identifier',

        'comment' => 'comment',
        'instantiation label' => 'label',
        'instantiation id' => 'id',
        'instantiation streaming url' => 'hls_url',
        'instantiation duration' => 'duration',
        'instantiation mime type' => 'mime_type',
        'instantiation audio bitrate' => 'audio_bitrate',
        'instantiation audio codec' => 'audio_codec',
        'instantiation video bitrate' => 'video_bitrate',
        'instantiation video codec' => 'video_codec',
        'instantiation width' => 'width',
        'instantiation height' => 'height',
        'file label' => 'label',
        'file title' => 'title',
        'file location' => 'file_location',
        'file checksum' => 'file_checksum',
        'file size' => 'file_size',
        'file duration' => 'duration',
        'file aspect ratio' => 'display_aspect_ratio',
        'file frame size' => 'original_frame_size',
        'file format' => 'file_format',
        'file caption text' => 'captions',
        'file caption type' => 'captions_type',
        'file other id' => 'other_identifier',
        'file comment' => 'comment',
        'file date digitized' => 'date_digitized',
        'file thumbnail offset' => 'thumbnail_offset',
        'file poster offset' => 'poster_offset'

      }
      map[normalize_header(header)]
    end
  end
end
