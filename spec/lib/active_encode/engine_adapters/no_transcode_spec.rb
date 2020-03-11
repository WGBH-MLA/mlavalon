require 'rails_helper'
require 'active_encode'

# TODO: Submit PR to active_encode shared examples.
gem_dir = Gem.find_files(:active_encode).detect { |entry| File.directory? entry }
require File.join(File.expand_path('../../', gem_dir), 'spec', 'shared_specs', 'engine_adapter_specs')

RSpec.describe ActiveEncode::EngineAdapters::NoTranscode do
  require 'rspec/its' # this is used within the shared spec.

  let(:low_derivative) { "file://" + Rails.root.join('..', 'spec', 'fixtures', 'fireworks.low.mp4').to_s }
  let(:file) { "file://" + Rails.root.join('..', 'spec', 'fixtures', 'fireworks.mp4').to_s }

  let(:created_job) do
    ActiveEncode::Base.create(file, outputs: [{ label: 'low', url: low_derivative }])
  end
  let(:running_job) do
    created_job
  end
  let(:canceled_job) do
    find_encode 'cancelled-id'
  end
  # TODO: ActiveEncode depends on this variable, but doesn't check for like it
  # does the others. Submit a PR to active_encode?
  let(:cancelling_job) do
    find_encode 'running-id'
  end

  let(:completed_job) { find_encode "completed-id" }
  let(:failed_job) { find_encode 'failed-id' }

  let(:completed_tech_metadata) do
    {
      audio_bitrate: 171_030,
      audio_codec: 'mp4a-40-2',
      duration: 6315.0,
      file_size: 199_160,
      frame_rate: 23.719,
      height: 110.0,
      id: "completed-id",
      url: "/home/pdinh/Downloads/videoshort.mp4",
      video_bitrate: 74_477,
      video_codec: 'avc1',
      width: 200.0
    }
  end
  let(:completed_output) { [{ id: "completed-id" }] }
  let(:failed_tech_metadata) { {} }

  it_behaves_like 'an ActiveEncode::EngineAdapter'
end
