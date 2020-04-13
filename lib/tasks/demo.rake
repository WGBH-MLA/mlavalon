require 'demo'

namespace :demo do
  desc 'initialize Avalon for demo'
  task init: :environment do
    # Add in anything else required for Demo setup here.
    Demo.user && Demo.api_token
  end

  desc 'reset Avalon for demo'
  task reset: :environment do
    Rake::Task['avalon:wipeout'].invoke
    Rake::Task['demo:init'].invoke
  end

  desc 'Converts a MARS csv data export to an Avalon batch ingest'
  task mars_export_to_avalon_batch: :init do
    require 'mars'
    MARS::AvalonBatchIngestGenerator.new(
      export_data: MARS::ExportData.new(filename: ENV['file']),
      submitter: Demo.user.username,
      api_host: Demo.api_host,
      api_port: Demo.api_port,
      api_token: Demo.api_token
    ).generate
  end

  desc 'Run demo ingest'
  task :ingest do
    Rake::Task['demo:reset'].invoke
    Rake::Task['demo:mars_export_to_avalon_batch'].invoke
    Rake::Task['avalon:batch:ingest'].invoke
  end
end
