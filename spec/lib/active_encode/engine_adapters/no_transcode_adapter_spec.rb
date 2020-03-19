require 'rails_helper'
require 'active_encode'

# TODO: Submit PR to active_encode shared examples.
gem_dir = Gem.find_files(:active_encode).detect { |entry| File.directory? entry }
require File.join(File.expand_path('../../', gem_dir), 'spec', 'shared_specs', 'engine_adapter_specs')

RSpec.describe ActiveEncode::EngineAdapters::NoTranscodeAdapter do
  require 'rspec/its' # this is used within the shared spec.

  around do |example|
    ActiveEncode::Base.engine_adapter = :no_transcode
    example.run
    ActiveEncode::Base.engine_adapter = :test
  end

  let(:job_id) { 'FAKE-JOB-ID' }
  let(:file_path) { 'path/to/file.mp4' }

  let(:created_job) { ActiveEncode::Base.create(file_path) }
  let(:running_job) { created_job }

  let(:canceled_job) do
    ActiveEncode::Base.find(job_id).cancel!
  end
  # TODO: ActiveEncode depends on this variable, but doesn't check for like it
  # does the others. Submit a PR to active_encode?
  let(:cancelling_job) do
    ActiveEncode::Base.find job_id
  end

  let(:completed_job) { ActiveEncode::Base.find job_id }
  let(:failed_job) { ActiveEncode::Base.find job_id }

  let(:completed_tech_metadata) { { } }
  # let(:completed_tech_metadata) do
  #   {
  #     audio_bitrate: 171_030,
  #     audio_codec: 'mp4a-40-2',
  #     duration: 6315.0,
  #     file_size: 199_160,
  #     frame_rate: 23.719,
  #     height: 110.0,
  #     id: "completed-id",
  #     url: "/home/pdinh/Downloads/videoshort.mp4",
  #     video_bitrate: 74_477,
  #     video_codec: 'avc1',
  #     width: 200.0
  #   }
  # end
  let(:completed_output) { [{}] }
  let(:failed_tech_metadata) { {} }

  it_behaves_like 'an ActiveEncode::EngineAdapter'
end
