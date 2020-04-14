FactoryBot.define do
  factory :mars_manifest, class: MarsManifest do
    url { 'http://foo.edu/fake_manifest.csv'}

    transient do
      add_headers { [] }
      add_values { [] }
      blank_values_for { [] }
      num_rows { 10 }

      headers do
        [
          "Collection Name",
          "Collection Description",
          "Unit Name",
          "Collection ID",
          "Title",
          "Date Issued",
          ["Creator"] * rand(1..4),
          ["Alternative Title"] * rand(1..4),
          ["Translated Title"] * rand(1..4),
          ["Uniform Title"] * rand(1..4),
          "Statement Of Responsibility",
          "Date Created",
          "Copyright Date",
          "Abstract",
          ["Note"] * rand(1..4),
          "Format",
          ["Resource Type"] * rand(1..4),
          ["Contributor"] * rand(1..4),
          ["Publisher"] * rand(1..4),
          ["Genre"] * rand(1..4),
          ["Subject"] * rand(1..4),
          ["Related Item Url"] * rand(1..4),
          ["Geographic Subject"] * rand(1..4),
          ["Temporal Subject"] * rand(1..4),
          ["Topical Subject"] * rand(1..4),
          "Bibliographic Id",
          ["Language"] * rand(1..4),
          "Terms Of Use",
          ["Tables Of Content"] * rand(1..4),
          "Physical Description",
          ["Other Identifier", "Other Identifier Type"] * rand(1..4),
          ["Comment"] * rand(1..4),
          [
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
          ] * rand(1..4)
        ].flatten
      end
    end

    initialize_with do
      new(url: url)
    end

    after(:build) do |mars_manifest, evaluator|
      headers = evaluator.headers
      rows = evaluator.num_rows.times.map { MarsManifestFaker.fake_row_for(headers) }


      unless evaluator.add_headers.empty?
        Array(evaluator.add_headers).each do |header|
          headers << header
        end
      end

      # If built with :blank_values_for, remove all values for those headers.
      # This helps test error case for missing required values.
      # Usage: build(:mars_manifest. blank_values_for: 'Collection Name')
      # unless evaluator.blank_values_for.empty?
      #   Array(evaluator.blank_values_for).each do |blank_value_for|
      #     headers.each_with_index do |header, index|
      #       values[index] = nil if header == blank_value_for
      #     end
      #   end
      # end

      # If built with :add_values, add them to the @values attribute. This
      # helps us test the error condition for row data without headers.
      # Usage: build(:mars_manifest. add_values: ['foo', 'bar'])
      # unless evaluator.add_values.empty?
      #   Array(evaluator.add_values).each do |value|
      #     values << value
      #   end
      # end


      rows.unshift headers
      # TODO: properly escape quotes?
      raw_data = rows.map { |row| row.join(',') }.join("\n")
      mars_manifest.instance_variable_set(:@raw_data, raw_data)
    end
  end
end
