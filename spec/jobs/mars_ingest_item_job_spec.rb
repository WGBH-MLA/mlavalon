require 'rails_helper'

describe MarsIngestItemJob do
  let(:mars_ingest_item) { FactoryBot.create(:mars_ingest_item) }
  let(:job) { described_class.new(mars_ingest_item.id) }

  context 'with a successful post to the Ingest API' do
    before do
      stub_request(:any, "http://localhost:3000/media_objects.json").to_return(:body => "true", :status => 200, :headers => {})
    end

    describe "perform" do
       it 'sets the job_id on the MarsIngestItem' do
        job.perform_now
        mars_ingest_item.reload
        expect(mars_ingest_item.job_id).to eq(job.job_id)
      end
    end

    context 'ActiveJob Callbacks' do
      before do
        allow(job).to receive(:perform).and_return(true)
      end

      describe 'after_enqueue' do
        it 'updates the MarsIngestItem#status to enqueued' do
          allow(job).to receive(:set_processing_status).and_return(true)
          allow(job).to receive(:set_final_status).and_return(true)
          job.perform_now
          expect(mars_ingest_item.reload.status).to eq('enqueued')
        end
      end

      describe 'before_perform' do
        it 'updates the MarsIngestItem#status to processing' do
          allow(job).to receive(:set_final_status).and_return(true)
          job.perform_now
          expect(mars_ingest_item.reload.status).to eq('processing')
        end
      end

      describe 'after_perform' do
        it 'updates the MarsIngestItem#status to succeeded' do
          job.perform_now
          expect(mars_ingest_item.reload.status).to eq('succeeded')
        end
      end
    end
  end

  context 'with an unsuccessful post to the Ingest API' do
    before do
      stub_request(:any, "http://localhost:3000/media_objects.json").to_return(:body => "{ :errors => [\"error 1\", \"error 2\"]", :status => 422, :headers => {})
    end

    describe 'after_perform' do
      it 'updates the MarsIngestItem#status to succeeded' do
        job.perform_now
        expect(mars_ingest_item.reload.status).to eq('failed')
      end
    end
  end

#  the rescue_from callback retries the job if the Ingest API fails with a "record already exists".

end
