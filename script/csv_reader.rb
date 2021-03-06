require 'csv'
require 'rest-client'
require 'json'
# require_relative '../config/environment'

class CSVReader

  def fetch_collection_json(collection_id)
    port = '80'
    params = {
      method: :get,
      url: "http://localhost:#{port}/admin/collections/#{collection_id}.json",
      headers: {
        content_type: :json,
        accept: :json,
        :'Avalon-Api-Key' => ENV['AVALON_API_KEY']
      },
      verify_ssl: false,
      timeout: 15
    }

    send_request(params)
  end

  def fetch_all_collections_json
    port = '80'
    params = {
      method: :get,
      url: "http://localhost:#{port}/admin/collections.json?per_page=1000&page=1",
      headers: {
        content_type: :json,
        accept: :json,
        :'Avalon-Api-Key' => ENV['AVALON_API_KEY']
      },
      verify_ssl: false,
      timeout: 15
    }
    send_request params
  end

  def fetch_collection_by_name(collection_name)
    fetch_all_collections_json.select { |collection_json| collection_json['name'] == collection_name }.first
  end


  def generate_payload(media_object_data, collection_id)
    puts "Generating Payload..."
    {
      fields: {
        title: media_object_data['Title'],
        date_issued: media_object_data['Date Issued'],

        creator: media_object_data['Creators'], #multiple
        alternative_title: media_object_data['Alternative Titles'], #multiple
        translated_title: media_object_data['Translated Titles'], #multiple
        uniform_title: media_object_data['Uniform Titles'], #multiple
        statement_of_responsibility: media_object_data['Statement Of Responsibility'],
        date_created: media_object_data['Date Created'],
        copyright_date: media_object_data['Copyright Date'],
        abstract: media_object_data['Abstract'],
        note: media_object_data['Notes'], #multiple, requires paired note_type
        format: media_object_data['Format'],
        resource_type: media_object_data['Resource Types'], #multiple
        contributor: media_object_data['Contributors'], #multiple
        publisher: media_object_data['Publishers'], #multiple
        genre: media_object_data['Genres'], #multiple
        subject: media_object_data['Subjects'], #multiple
        related_item_url: media_object_data['Related Item Urls'], #multiple, requires paired related_item_label
        geographic_subject: media_object_data['Geographic Subjects'], #multiple
        temporal_subject: media_object_data['Temporal Subjects'], #multiple
        topical_subject: media_object_data['Topical Subjects'], #multiple
        bibliographic_id: media_object_data['Bibliographic Id'],
        language: media_object_data['Languages'], #multiple
        terms_of_use: media_object_data['Terms Of Use'],
        table_of_contents: media_object_data['Tables Of Contents'], #multiple
        physical_description: media_object_data['Physical Description'],
        other_identifier: media_object_data['Other Identifiers'], #multiple
        comment: media_object_data['Comments'] #multiple
      },

      collection_id: collection_id,

      files: [
        {
          label: media_object_data['File Label'], #optional
          title: media_object_data['File Title'],

          files: [{
                    label: media_object_data['Instantiation Label'],
                    id: media_object_data['Instantiation Id'],
                    url: media_object_data['Instantiation Streaming URL'],
                    hls_url: media_object_data['Instantiation Streaming URL'],
                    duration: media_object_data['Instantiation Duration'],
                    mime_type:  media_object_data['Instantiation Mime Type'],
                    audio_bitrate: media_object_data['Instantiation Audio Bitrate'],
                    audio_codec: media_object_data['Instantiation Audio Codec'],
                    video_bitrate: media_object_data['Instantiation Video Bitrate'],
                    video_codec: media_object_data['Instantiation Video Codec'],
                    width: media_object_data['Instantiation Width'],
                    height: media_object_data['Instantiation Height']
                  }],

          file_location: media_object_data['File Location'],
          file_checksum: media_object_data['File Checksum'],
          file_size: media_object_data['File Size'],
          duration: media_object_data['File Duration'],
          display_aspect_ratio: media_object_data['File Aspect Ratio'],
          original_frame_size: media_object_data['File Frame Size'],
          file_format: media_object_data['File Format'],

          # dont think we have this data
          # poster_offset: "0:02",
          # thumbnail_offset: "0:02",

          captions: media_object_data['File Caption Text'],

          # captions_type: 'text/vtt' (or 'text/srt')
          captions_type: media_object_data['File Caption Type'],

          # CI id or something I guess
          other_identifier: media_object_data['File Other Id'], #multiple
          comment: media_object_data['File Comment'], #multiple
          date_digitized: media_object_data['File Date Digitized'],

          # we might generate this presentation thingy with script in the future...
          # structure: "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!-- Music for Piano; http://server1.variations2.indiana.edu/variations/cgi-bin/access.pl?id=BFJ6801 -->\n<Item label=\"CD 1\">\n    <Div label=\"Copland, Three Piano Excerpts from Our Town\">\n        <Span label=\"Track 1. Story of Our Town\" begin=\"0\" end=\"0:09.99\"/>\n        <Span label=\"Track 2. Conversation at the Soda Fountain\" begin=\"0:10\" end=\"0:19.99\"/>\n        <Span label=\"Track 3. The Resting Place on the Hill\" begin=\"0:20\" end=\"0:29.99\"/>\n    </Div>\n    <Div label=\"Copland, Four Episodes from Rodeo\">\n        <Span label=\"Track 4. Buckaroo Holiday\" begin=\"0:30\" end=\"0:39.99\"/>\n        <Span label=\"Track 5. Corral Nocturne\" begin=\"0:40\" end=\"0:49.99\"/>\n        <Span label=\"Track 6. Saturday Night Waltz\" begin=\"0:50\" end=\"0:59.99\"/>\n        <Span label=\"Track 7. Hoe-Down\" begin=\"1:00\" end=\"1:09.99\"/>\n    </Div>\n    <Span label=\"Track 8. Copland, Piano Variations \" begin=\"1:10\" end=\"1:19.99\"/>\n    <Div label=\"Copland, Four Piano Blues\">\n        <Span label=\"Track 9. For Leo Smit: Freely poetic\" begin=\"1:20\" end=\"1:29.99\"/>\n        <Span label=\"Track 10. For Andor Foldes: Soft and languid\" begin=\"1:30\" end=\"1:39.99\"/>\n        <Span label=\"Track 11. For Willian Kapell: Muted and sensuous\" begin=\"1:40\" end=\"1:49.99\"/>\n        <Span label=\"Track 12. For John Kirkpatrick: WIth bounce\" begin=\"1:50\" end=\"1:59.99\"/>\n    </Div>\n    <Span label=\"Track 13. Copland, Danzon Cubano\" begin=\"2:00\" end=\"2:30\"/>\n</Item>\n",

          # Not sure what this is for!
          workflow_name: "avalon",
          percent_complete: "100.0",
          percent_succeeded: "100.0",
          percent_failed: "0",
          status_code: "COMPLETED"
        }
      ]
    }
  end

  def is_collection_row?(row_data)
    ['Collection Name','Collection Description','Unit Name','Collection ID',].any? { |field| !row_data[field].nil? }
  end

  def ingest_one_record(collection_id, payload)
    port = '80'
    params = {
      method: :post,
      url: "http://localhost:#{port}/media_objects.json",
      payload: payload,
      headers: {
        content_type: :json,
        accept: :json,
        :'Avalon-Api-Key' => ENV['AVALON_API_KEY']
      },
      verify_ssl: false,
      timeout: 15
    }

    send_request params
  end

  def create_collection(row_data)
    port = '80'
    payload = { admin_collection: {} }
    payload[:admin_collection][:name] = row_data['Collection Name'] if row_data['Collection Name']
    payload[:admin_collection][:description] = row_data['Collection Description'] if row_data['Collection Description']
    payload[:admin_collection][:unit] = row_data['Unit Name'] if row_data['Unit Name']
    payload[:admin_collection][:managers] = ["woo@foo.edu"]

    puts "Creating collection with payload = #{payload}"

    params = {
      method: :post,
      url: "http://localhost:#{port}/admin/collections.json",
      payload: payload,
      headers: {
        content_type: :json,
        accept: :json,
        :'Avalon-Api-Key' => ENV['AVALON_API_KEY']
      },
      verify_ssl: false,
      timeout: 15
    }

    send_request params
  end

  def send_request(params)
    JSON.parse(RestClient::Request.execute(params))
  rescue => e
    puts "#{e.class}: #{e.message}"
    puts "API Response: #{e.response}"
  end

  def find_or_create_collection(row_data)
    if !row_data['Collection ID'].nil?
      # Admin::Collection.find(row_data['Collection ID'])
      collection = fetch_collection_json(row_data['Collection ID'])
    else
      collection = fetch_collection_by_name(row_data['Collection Name'])
      collection ||= create_collection(row_data)
      # Admin::Collection.where({name: row_data['Collection Name']}).first || Admin::Collection.create({name: row_data['Collection Name'], unit: row_data['Unit Name'], description: row_data['Collection Description']})
    end
    raise "Collection could not be created nor found with row data = #{row_data}" unless collection
    collection
  end

  def ingest_csv(filename)

    collection = nil

    CSV.read(filename, {headers: true}).each do |csv_line|

      # collection row
      if is_collection_row?(csv_line)
        puts "Starting Collection Row..."
        collection = find_or_create_collection(csv_line)
        # update collection metadata if submitted
        # collection.name = csv_line['Collection Name'] + SecureRandom.hex.slice(0..10) if csv_line['Collection Name']
        # collection.description = csv_line['Collection Description'] if csv_line['Collection Description']
        # collection.unit = csv_line['Unit Name'] if csv_line['Unit Name']
        # collection.managers = ["woo@foo.edu"]
        # collection.save!
      else
        puts "Starting MediaObject Row..."
        payload = generate_payload(csv_line, collection['id'])
        ingest_one_record(collection['id'], payload)
      end

    end

    puts "Buh-Bye!"
  end
end
