require 'json'
require 'uri'

class MarsIngestItem < ActiveRecord::Base
  belongs_to :mars_ingest

  # csv row objec
  attr_accessor :csv_row_hash

  before_validation :parse_json
  def parse_json
    if csv_row_hash
      self.row_payload = create_json_payload(csv_row_hash)
    end
  end

  # validates do
  #   # runs the marsingestrow validations
  # end

  validates :mars_ingest_id, presence: true
  validates :row_payload, presence: true
  validates :mars_ingest_id, presence: true
  validates :status, inclusion: %w(enqueued processing failed succeeded)
  validate :valid_json_parse

  def valid_json_parse
    begin
      JSON.parse(create_json_payload(csv_row_hash))
    rescue JSON::ParserError
      false
    end
  end

  def create_json_payload(csv_row_hash)
    {
      fields: {
        title: csv_row_hash['Title'],
        date_issued: csv_row_hash['Date Issued'],

        creator: csv_row_hash['Creators'], #multiple
        alternative_title: csv_row_hash['Alternative Titles'], #multiple
        translated_title: csv_row_hash['Translated Titles'], #multiple
        uniform_title: csv_row_hash['Uniform Titles'], #multiple
        statement_of_responsibility: csv_row_hash['Statement Of Responsibility'],
        date_created: csv_row_hash['Date Created'],
        copyright_date: csv_row_hash['Copyright Date'],
        abstract: csv_row_hash['Abstract'],
        note: csv_row_hash['Notes'], #multiple, requires paired note_type
        format: csv_row_hash['Format'],
        resource_type: csv_row_hash['Resource Types'], #multiple
        contributor: csv_row_hash['Contributors'], #multiple
        publisher: csv_row_hash['Publishers'], #multiple
        genre: csv_row_hash['Genres'], #multiple
        subject: csv_row_hash['Subjects'], #multiple
        related_item_url: csv_row_hash['Related Item Urls'], #multiple, requires paired related_item_label
        geographic_subject: csv_row_hash['Geographic Subjects'], #multiple
        temporal_subject: csv_row_hash['Temporal Subjects'], #multiple
        topical_subject: csv_row_hash['Topical Subjects'], #multiple
        bibliographic_id: csv_row_hash['Bibliographic Id'],
        language: csv_row_hash['Languages'], #multiple
        terms_of_use: csv_row_hash['Terms Of Use'],
        table_of_contents: csv_row_hash['Tables Of Contents'], #multiple
        physical_description: csv_row_hash['Physical Description'],
        other_identifier: csv_row_hash['Other Identifiers'], #multiple
        comment: csv_row_hash['Comments'] #multiple
      },

      collection_id: csv_row_hash['Collection Name'],

      files: [
        {
          label: csv_row_hash['File Label'], #optional
          title: csv_row_hash['File Title'],

          files: [{
                    label: csv_row_hash['Instantiation Label'],
                    id: csv_row_hash['Instantiation Id'],
                    url: csv_row_hash['Instantiation Streaming URL'],
                    hls_url: csv_row_hash['Instantiation Streaming URL'],
                    duration: csv_row_hash['Instantiation Duration'],
                    mime_type:  csv_row_hash['Instantiation Mime Type'],
                    audio_bitrate: csv_row_hash['Instantiation Audio Bitrate'],
                    audio_codec: csv_row_hash['Instantiation Audio Codec'],
                    video_bitrate: csv_row_hash['Instantiation Video Bitrate'],
                    video_codec: csv_row_hash['Instantiation Video Codec'],
                    width: csv_row_hash['Instantiation Width'],
                    height: csv_row_hash['Instantiation Height']
                  }],

          file_location: csv_row_hash['File Location'],
          file_checksum: csv_row_hash['File Checksum'],
          file_size: csv_row_hash['File Size'],
          duration: csv_row_hash['File Duration'],
          display_aspect_ratio: csv_row_hash['File Aspect Ratio'],
          original_frame_size: csv_row_hash['File Frame Size'],
          file_format: csv_row_hash['File Format'],

          # decide good defaults for this 
          poster_offset: "0:02",
          thumbnail_offset: "0:02",

          captions: csv_row_hash['File Caption Text'],

          # captions_type: 'text/vtt' (or 'text/srt')
          captions_type: csv_row_hash['File Caption Type'],

          # CI id or something I guess
          other_identifier: csv_row_hash['File Other Id'], #multiple
          comment: csv_row_hash['File Comment'], #multiple
          date_digitized: csv_row_hash['File Date Digitized'],

          # we might generate this presentation thingy with script in the future...
          # structure: "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!-- Music for Piano; http://server1.variations2.indiana.edu/variations/cgi-bin/access.pl?id=BFJ6801 -->\n<Item label=\"CD 1\">\n    <Div label=\"Copland, Three Piano Excerpts from Our Town\">\n        <Span label=\"Track 1. Story of Our Town\" begin=\"0\" end=\"0:09.99\"/>\n        <Span label=\"Track 2. Conversation at the Soda Fountain\" begin=\"0:10\" end=\"0:19.99\"/>\n        <Span label=\"Track 3. The Resting Place on the Hill\" begin=\"0:20\" end=\"0:29.99\"/>\n    </Div>\n    <Div label=\"Copland, Four Episodes from Rodeo\">\n        <Span label=\"Track 4. Buckaroo Holiday\" begin=\"0:30\" end=\"0:39.99\"/>\n        <Span label=\"Track 5. Corral Nocturne\" begin=\"0:40\" end=\"0:49.99\"/>\n        <Span label=\"Track 6. Saturday Night Waltz\" begin=\"0:50\" end=\"0:59.99\"/>\n        <Span label=\"Track 7. Hoe-Down\" begin=\"1:00\" end=\"1:09.99\"/>\n    </Div>\n    <Span label=\"Track 8. Copland, Piano Variations \" begin=\"1:10\" end=\"1:19.99\"/>\n    <Div label=\"Copland, Four Piano Blues\">\n        <Span label=\"Track 9. For Leo Smit: Freely poetic\" begin=\"1:20\" end=\"1:29.99\"/>\n        <Span label=\"Track 10. For Andor Foldes: Soft and languid\" begin=\"1:30\" end=\"1:39.99\"/>\n        <Span label=\"Track 11. For Willian Kapell: Muted and sensuous\" begin=\"1:40\" end=\"1:49.99\"/>\n        <Span label=\"Track 12. For John Kirkpatrick: WIth bounce\" begin=\"1:50\" end=\"1:59.99\"/>\n    </Div>\n    <Span label=\"Track 13. Copland, Danzon Cubano\" begin=\"2:00\" end=\"2:30\"/>\n</Item>\n",

          workflow_name: "avalon",
          percent_complete: "100.0",
          percent_succeeded: "100.0",
          percent_failed: "0",
          status_code: "COMPLETED"
        }
      ]
    }.to_json
  end
end

