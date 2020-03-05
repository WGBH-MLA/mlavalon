require 'demo'

namespace :demo do
  desc 'setup Avalon for demo'
  task setup: :environment do
    # Add in anything else required for Demo setup here.
    Demo.user && Demo.api_token
  end

  desc 'Converts a MARS csv data export to an Avalon batch ingest'
  task mars_export_to_avalon_batch: 'demo:setup' do
    require 'mars'
    MARS::AvalonBatchIngestGenerator.new(
      export_data: MARS::ExportData.new(filename: ENV['file']),
      submitter: Demo.user.username,
      api_host: Demo.api_host,
      api_port: Demo.api_port,
      api_token: Demo.api_token
    ).generate
  end
end
