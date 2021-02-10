class ManifestToPayloadMapper
  Field = Struct.new(:header, :value)

  delegate :collection_header?, :media_object_header?, :notes_header?, :file_header?,
    :initial_file_header?, :instantiation_header?, :other_id_header?, :normalize_header,
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
      p['publish'] = "true"
    end

    pl = @payload.clone
    pl = compact_hash(pl)
    zl = pl.clone
    @payload = deep_correct_encoding(zl)
  end

  def contains_truth?(ele)
    return false if ele == ""
    return false if ele.nil?
    return false if ele == [{}]
    return false if ele == {}
    return false if ele == []

    if ele.is_a?(Hash)
      return false unless ele.values.any? {|v| contains_truth?(v) }
    end

    if ele.is_a?(Array)
      return false unless ele.any? {|element| contains_truth?(element) }
    end

    true
  end

  def compact_hash(hash)
    newhash = {}
    hash.each do |k,v|

      # skip this element unless there is something, somewhere, inside
      next unless contains_truth?(v)

      if v.is_a?(Array)

        if v.all? {|element| element.is_a?(Hash) }

          v.each do |hashito|

            # if array of hashes, do it again for next layer, IF theres actually something in the hash
            if contains_truth?(hashito)
              newhash[k] ||= []
              newhash[k] << compact_hash(hashito)
            end
          end
        else

          # its a multivalued field, pass on the real values in this array
          newhash[k] = v.select { |value| contains_truth?(value) }
        end

      elsif v.is_a?(String)

        # its a single value field, only pass key through if value
        newhash[k] = v
      elsif v.is_a?(Hash)

        # this key is a hash, with SOMETHING init, do it again for this layer
        newhash[k] = compact_hash(v)
      end
    end

    newhash
  end

  def deep_correct_encoding(hash)
    hash.transform_values do |v|
      if v.is_a?(Hash)
        deep_correct_encoding(v)
      elsif v.is_a?(Array)

        if v.all? {|ele| ele.is_a?(Hash) }

          v.map { |ele| deep_correct_encoding(ele) }
        else

          v.map {|ele| ele.to_s.encode('UTF-8', invalid: :replace, undef: :replace, replace: '?').force_encoding('UTF-8')}
        end
      else
        v.to_s.encode('UTF-8', invalid: :replace, undef: :replace, replace: '?').force_encoding('UTF-8')
      end
    end
  end

  private

    # Returns a found (or new) collection based on the collection fields and
    # the submitter's email.
    def collection
      Rails.logger.info "XXXXX COLLECTION NAME #{collection_hash['collection name']}"

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

      other_id_fields.each do |other_id_field|
        other_id['other_identifier_type'] << api_field_name_for(other_id_field.header)
        other_id['other_identifier'] << other_id_field.value
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
      # sub out vertical tabs, they are expected in mars exports
      # for evil quotes, explicitly sub out the offending byte sequences themselves to non-hated characters
      val.to_s.force_encoding('UTF-8').gsub(/[\t\v]/, " ").gsub(/\xE2\x80\x98/, %(')).gsub(/\xE2\x80\x99/, %(')).gsub(/\xE2\x80\x9C/, %(")).gsub(/\xE2\x80\x9D/, %("))
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
        'mla barcode' => 'mla barcode',
        'media pim id' => 'media pim id',

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
