require 'rails_helper'

describe MarsIngestItemJob, type: :job do

  before :all do
    ActiveJob::Base.queue_adapter = :test
  end

  let(:mars_ingest_item) { FactoryBot.create(:mars_ingest_item) }
  let(:job) { described_class.new(mars_ingest_item.id) }

  describe '.perform_later' do
    before do
      described_class.perform_later(mars_ingest_item.id)
    end

    it 'enqueues the job and sets the status of the MarsIngestItem to "enqueued"' do
      expect(described_class).to have_been_enqueued.exactly(:once).with(mars_ingest_item.id)
      expect(mars_ingest_item.reload.status).to eq 'enqueued'
    end
  end

  describe '#perform_now' do
    context 'when #perform method does not raise an error' do
      before do
        allow(job).to receive(:perform).with(mars_ingest_item.id).and_return(true)
        allow(job).to receive(:update_status).with(any_args)
        job.perform_now
      end

      it 'updates the status to "processing", then to "succeeded"' do
        expect(job).to have_received(:update_status).with('processing').exactly(:once).ordered
        expect(job).to have_received(:update_status).with('succeeded').exactly(:once).ordered
      end
    end

    context 'when #perform method raises an error' do
      let(:error) { 'Wtf?'}
      before do
        allow(job).to receive(:perform).with(mars_ingest_item.id).and_raise(error)
        allow(job).to receive(:update_status).with(any_args)
        job.perform_now
      end

      it 'updates the status to "processing", then to "failed"' do
        expect(job).to have_received(:update_status).with('processing').exactly(:once).ordered
        expect(job).to have_received(:update_status).with('failed', error).exactly(:once).ordered
      end
    end

    context 'with a successful post to the Ingest API' do
      before do
        stub_request(:any, "http://localhost:3000/media_objects.json").to_return(:body => "true", :status => 200, :headers => {})
        job.perform_now
        mars_ingest_item.reload
      end

      it 'sets the job_id on the MarsIngestItem' do
        expect(mars_ingest_item.job_id).to eq(job.job_id)
      end
    end
  end

  context 'with an unsuccessful post to the Ingest API' do
    let(:errors) { ["that ain't right", "nope, it sure ain't"] }

    before do
      stub_request(:post, "http://localhost:3000/media_objects.json").to_return( body: { errors: errors }.to_json, :status => 422, :headers => {})
      job.perform_now
      mars_ingest_item.reload
    end

    describe 'after_perform' do
      it 'updates the MarsIngestItem#status to failed' do
        expect(mars_ingest_item.status).to eq('failed')
        expect(mars_ingest_item.error).to eq(errors.to_json)
      end
    end
  end
end
