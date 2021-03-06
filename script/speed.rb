require_relative '../lib/benchmarks'
require 'fileutils'
require 'rest-client'

# Fetch params from ENV; set defaults if empty.
trials = ENV.fetch('TRIALS', 10).to_i
collection_id = ENV.fetch('COLLECTION_ID')
timestamp = Time.now.strftime('%Y%m%d-%H%M%S')
output_file = ENV.fetch('OUTPUT_FILE', "./benchmark_results/#{timestamp}.#{trials}_generic_works.csv")

# Create a place for the output file if needed.
FileUtils.mkdir_p File.dirname output_file

payload = {
  fields: {
    title: 'Test Ingested Object',
    date_issued: DateTime.now
  },
  collection_id: collection_id,
  files: [
    {
      # file_location: '',
      title: 'Baby Eleanor',
      files: [
        {
          label: 'quality-high',
          id: 'track-1',
          url: "https://avalon.wgbh.org/hls/avalon/baby_eleanor.mp4/master.m3u8",
          # duration: "6315",
          # mime_type:  "video/mp4",
          # audio_bitrate: "127716.0",
          # audio_codec: "AAC",
          # video_bitrate: "1000000.0",
          # video_codec: "AVC",
          # width: "640",
          # height: "480"
        },
      ],
      workflow_name: "avalon",
      percent_complete: "100.0",
      percent_succeeded: "100.0",
      percent_failed: "0",
      status_code: "COMPLETED"
    }
  ]
}

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


# Create the bnechmark.
b = Hyrax::Benchmark.new(output_file: output_file)
b.procedure do
  resp = RestClient::Request.execute(params)
  # generic_work = GenericWork.new title: ["some title"]
  # ability = Ability.new depositor
  # env = Hyrax::Actors::Environment.new(generic_work, ability, {})
  # actor = Hyrax::CurationConcern.actor
  # raise "Failed to save record:\n#{generic_work.errors.messages.join("\n")}" unless actor.create(env)
end

b.run(trials: trials)
# Specify a measurement for Fedora repository size.
# b.measure(:fcr_objects) { ActiveFedora::Base.count }

# Specify a measurement for Solr index size
# b.measure(:solr_docs) do
#   ActiveFedora.solr.conn.get(:select)['response']['numFound']
# end