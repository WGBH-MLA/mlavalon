module MARS
  # Model representing a MARS export, providing accessors to things we need
  # in order to prepare a batch ingest of MARS data into Avalon.
  class ExportData
    attr_reader :filename

    def initialize(filename:)
      raise ArgumentError, "Invalid MARS export data file: '#{filename}'" unless File.exists? filename.to_s
      @filename = File.expand_path(filename.to_s)
    end

    def csv
      @csv ||= CSV.read(filename)
    end

    def generate_avalon_batch_ingest
      ConvertToAvalonBatchIngest(export_data: self).convert
    end

    def rows_grouped_by_series
      @rows_grouped_by_series ||= begin
        grouped = {}
        rows.each do |row|
          row_hash = row.to_h
          series_name = row_hash.delete('Series Name').to_s.strip
          series_name = row_hash['Title'].to_s.strip if series_name.empty?
          series_name = "UNKNOWN" if series_name.empty?
          grouped[series_name] ||= []
          grouped[series_name] << row_hash
        end
        grouped
      end
    end

    def rows
      @rows ||= CSV.read( File.expand_path(filename), { headers: true, encoding: 'UTF-8' } )
    end
  end

  class AvalonBatchIngestGenerator
    attr_reader :export_data, :submitter, :api_host, :api_port, :api_token

    def initialize(export_data:, submitter:, api_host:, api_port:, api_token:)
      raise ArgumentError, "Expeted MARS::ExportData instance, but #{export_data.class} was given" unless export_data.is_a? ::MARS::ExportData
      @export_data = export_data
      @submitter = submitter
      @api_host = api_host
      @api_port = api_port
      @api_token = api_token
    end

    def generate

      # grouped by series is a
      # {
      #   "Nova": [{novarow1},{novarow1},{novarow1},],
      #   "Frontline": [etc...]
      # }
      FileUtils.mkdir_p Settings.dropbox.path

      export_data.rows_grouped_by_series.each do |series_name, rows|

        collection = find_collection(series_name) || create_collection(series_name)

        # tech rows
        # map through array of row_hashes, selecting only keys for technical metadata
        tech_metadata_rows = rows.map {|row_hash| row_hash.select {|k,v| ["Absolute Location", "Series Name", "file_format","duration","display_aspect_ratio","original_frame_size","poster_offset"].include?(k) } }
        write_tech_csv_for_collection(collection, tech_metadata_rows)

        # manifest rows
        # map through array of row_hashes, selecting only keys for manifest metadata
        manifest_rows = rows.map {|row_hash| row_hash.select {|k,v| ["file_format","duration","display_aspect_ratio","original_frame_size","poster_offset"].exclude?(k) } }
        write_manifest_csv_for_collection(collection, manifest_rows)
      end
    end

    private

      def write_tech_csv_for_collection(collection, rows)
        return unless collection
        filepath = File.join collection.dropbox_absolute_path, %(techdata.csv)
        puts "Writing #{rows.count} rows to techdata CSV for #{collection.name} at #{filepath} ..."

        CSV.open(filepath, 'wb') do |csv|
          # Write the headers (i.e. keys of the row hashes).
          csv << rows.first.keys
          # Write the rows (i.e. values of each row).
          rows.each_with_index do |row, i|
            # write csv data to one row
            csv << row.values
          end
        end
      end

      def write_manifest_csv_for_collection(collection, rows)
        # We rescue/log errors when finding or creating collections, so we need
        # to guard against the absence of a collection here.
        return unless collection
        filepath = File.join collection.dropbox_absolute_path, File.basename(export_data.filename)
        puts "Writing #{rows.count} rows to CSV for #{collection.name} at #{filepath} ..."

        CSV.open(filepath, 'wb') do |csv|
          # Write the top row of metadata: Batch name, sumbitter username
          csv << ["MARS export for #{collection.name}", submitter]
          # Write the headers (i.e. keys of the row hashes).
          csv << rows.first.keys
          # Write the rows (i.e. values of each row).
          rows.each_with_index do |row, i|
            # write csv data to one row
            csv << row.values

          end
        end
      end

      def find_collection(name)
        solr_response = ActiveFedora.solr.conn.get(:select, params: { q: "name_ssi:\"#{name}\"" })
        # Dig into the solr response for the Collection ID... it's in there I swear!
        collection_id = solr_response['response']['docs'].first&.fetch('id', nil)
        return unless collection_id
        Admin::Collection.find collection_id
      end

      def create_collection(name)
        payload = {
          admin_collection: {
            name: name,
            managers: [ submitter ],
            unit: "Default Unit"
          }
        }

        response = send_api_request(api_params_for_create_collection(payload: payload))
        # We rescue and log errors sent back from teh API, so here we need to
        # guard against a missing collection ID.
        return unless response
        # Return the saved collection.
        # TODO: If any background jobs were queued when creating the collection,
        # wait for them to finish.
        Admin::Collection.find(response['id'])
      end

      def api_params_for_create_collection(payload:)
        {
          method: :post,
          url: "http://#{api_host}:#{api_port}/admin/collections.json",
          payload: payload,
          headers: {
            content_type: :json,
            accept: :json,
            :'Avalon-Api-Key' => api_token
          },
          verify_ssl: false,
          timeout: 15
        }
      end

      def send_api_request(params)
        JSON.parse(RestClient::Request.execute(params))
      rescue => e
        puts "#{e.class}: #{e.message}"
        puts "API Response: #{e.try(:response)}"
      end
  end
end