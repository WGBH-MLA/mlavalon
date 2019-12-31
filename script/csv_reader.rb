require 'csv'

module CSVReader
  def generate_payloads(filename, collection_id)

    payloads = []

    CSV.read(filename, {headers: true}) do |csv_line|
      payload = {
        fields: {
          title: csv_line['Title'],
          date_issued: csv_line['Date Issued']
        },
        collection_id: collection_id,
        files: [{
          label: csv_line['File Label'],
          title: csv_line['File Title'],

          files: [{
                    label: csv_line['Instantiation Label'],
                    id: csv_line['Instantiation Id'],
                    url: csv_line['Instantiation Streaming URL'],
                    duration: csv_line['Instantiation Duration'],
                    mime_type:  csv_line['Instantiation Mime Type'],
                    audio_bitrate: csv_line['Instantiation Audio Bitrate'],
                    audio_codec: csv_line['Instantiation Audio Codec'],
                    video_bitrate: csv_line['Instantiation Video Bitrate'],
                    video_codec: csv_line['Instantiation Video Codec'],
                    width: csv_line['Instantiation Width'],
                    height: csv_line['Instantiation Height']
                  }],
          file_location: csv_line['File Location'],
          file_checksum: csv_line['File Checksum'],
          file_size: csv_line['File Size'],
          duration: csv_line['File Duration'],
          display_aspect_ratio: csv_line['File Aspect Ratio'],
          original_frame_size: csv_line['File Frame Size'],
          file_format: csv_line['File Format'],
          
          # dont think we have this data
          # poster_offset: "0:02",
          # thumbnail_offset: "0:02",
          

          date_digitized: csv_line['File Date Digitized'],
          captions: csv_line['File Caption Text'],

          # captions_type: 'text/vtt' (or 'text/srt')
          captions_type: csv_line['File Caption Type']

          # CI id or something I guess
          other_identifier: csv_line['File Other Id'],
          comment: csv_line['File Comment'],

          # we might generate this presentation thingy with script in the future...
          # structure: "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!-- Music for Piano; http://server1.variations2.indiana.edu/variations/cgi-bin/access.pl?id=BFJ6801 -->\n<Item label=\"CD 1\">\n    <Div label=\"Copland, Three Piano Excerpts from Our Town\">\n        <Span label=\"Track 1. Story of Our Town\" begin=\"0\" end=\"0:09.99\"/>\n        <Span label=\"Track 2. Conversation at the Soda Fountain\" begin=\"0:10\" end=\"0:19.99\"/>\n        <Span label=\"Track 3. The Resting Place on the Hill\" begin=\"0:20\" end=\"0:29.99\"/>\n    </Div>\n    <Div label=\"Copland, Four Episodes from Rodeo\">\n        <Span label=\"Track 4. Buckaroo Holiday\" begin=\"0:30\" end=\"0:39.99\"/>\n        <Span label=\"Track 5. Corral Nocturne\" begin=\"0:40\" end=\"0:49.99\"/>\n        <Span label=\"Track 6. Saturday Night Waltz\" begin=\"0:50\" end=\"0:59.99\"/>\n        <Span label=\"Track 7. Hoe-Down\" begin=\"1:00\" end=\"1:09.99\"/>\n    </Div>\n    <Span label=\"Track 8. Copland, Piano Variations \" begin=\"1:10\" end=\"1:19.99\"/>\n    <Div label=\"Copland, Four Piano Blues\">\n        <Span label=\"Track 9. For Leo Smit: Freely poetic\" begin=\"1:20\" end=\"1:29.99\"/>\n        <Span label=\"Track 10. For Andor Foldes: Soft and languid\" begin=\"1:30\" end=\"1:39.99\"/>\n        <Span label=\"Track 11. For Willian Kapell: Muted and sensuous\" begin=\"1:40\" end=\"1:49.99\"/>\n        <Span label=\"Track 12. For John Kirkpatrick: WIth bounce\" begin=\"1:50\" end=\"1:59.99\"/>\n    </Div>\n    <Span label=\"Track 13. Copland, Danzon Cubano\" begin=\"2:00\" end=\"2:30\"/>\n</Item>\n",

          # Not sure what this is for!
          workflow_name: "avalon",
          percent_complete: "100.0",
          percent_succeeded: "100.0",
          percent_failed: "0",
          status_code: "COMPLETED"
        }]
      }

      payloads << payload
    end

    return payloads
  end
end
