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
  let(:running_job) do
    created_job.tap do |job|
      job.state = :running
    end
  end

  # NoTranscode does not produce any actualy encode jobs, therefore it cannot
  # result in any canceled jobs. However, to make the shared spec work, we spoof
  # a canceled job here.
  let(:canceled_job) do
    ActiveEncode::Base.find(job_id).tap { |encode| encode.state = :cancelled }
  end
  # TODO: ActiveEncode depends on this variable, but doesn't check for like it
  # does the others. Submit a PR to active_encode?
  let(:cancelling_job) do
    ActiveEncode::Base.find job_id
  end

  let(:completed_job) { ActiveEncode::Base.find job_id }
  # NoTranscode does not actually trigger any real encode jobs, therefore said
  # nonexistent jobs cannot fail. But to pass the shared spec, spoof it here.
  let(:failed_job) do
    ActiveEncode::Base.find(job_id).tap do |encode|
      encode.state = :failed
      encode.errors = ["YOU SHALL NOT PASS!"]
    end
  end

  # Used to satisify shared specs.
  let(:completed_tech_metadata) { { } }
  let(:completed_output) { [{}] }
  let(:failed_tech_metadata) { {} }

  it_behaves_like 'an ActiveEncode::EngineAdapter'
end
