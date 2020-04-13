FactoryBot.define do
  factory :mars_manifest_row, class: MarsManifestRow do
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

    transient do
      add_values { [] }
      merge_values { [] }
      blank_values { [] }
    end

    initialize_with do
      values = headers.map { |header| MarsManifestFaker.fake_value_for(header) }
      require "pry"; binding.pry
      new(headers: headers, values: values)
    end

    after(:build) do |mars_manifest_row, evaluator|
      # Grab the headers and values before we mutate them. They'll be assigned
      # back to the MarsManifestRow instance at the bottom of the block.
      headers = mars_manifest_row.headers
      values = mars_manifest_row.values

      unless evaluator.blank_values.empty?
        Array(evaluator.blank_values).each do |header|
          # indexes =
        end
      end
      #     mars_manifest_row.header_indexes(subtract_header).each do |index|
      #       headers[index] = nil
      #       values[index] = nil
      #     end
      #   end
      #   mars_manifest_row.instance_variable_set(:@headers, headers.compact)
      # end

      # If built with :add, add them to the @values attribute. This
      # helps us test the error condition where row data exceeds the headers.
      # Usage: build(:mars_manifest_row. add: ['foo', 'bar'])
      # unless evaluator.add.empty?
      #   vals = mars_manifest_row.values
      #   mars_manifest_row.instance_variable_set(:@values, vals + Array(evaluator.add))
      # end

      # If built with :merge, merge the values from the :merge hash
      # into the @values attribute.
      # unless evaluator.merge.empty?
      #   vals = mars_manifest_row.values
      #   evaluator.merge.each do |header, value|
      #
      #     mars_manifest_row.header_indexes(header).each do |header_index|
      #       vals[header_index] = ''
      #     end
      #   end
      #   mars_manifest_row.instance_variable_set(:@values, vals)
      # end

      # Reset the headers and values to the mutated arrays.
      mars_manifest_row.instance_variable_set(:@headers, headers)
      mars_manifest_row.instance_variable_set(:@values, values)
    end
  end
end
