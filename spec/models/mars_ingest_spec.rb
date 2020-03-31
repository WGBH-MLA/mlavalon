require 'rails_helper'

describe MarsIngest do
  let(:csv) { CSV.new(open("/home/app/avalon/spec/fixtures/sample_csv_ingest/sample_csv_ingest_1.csv"), :headers => :first_row) }

  before do
    allow(subject).to receive(:mars_ingest_csv).and_return(csv)
  end

  describe '#save' do
    subject { FactoryBot.build(:mars_ingest) }

    it 'persists with a manifest_url' do
      subject.save
      subject.reload
      expect(subject.manifest_url).to be_present
      expect(subject.item_count).to be_present
      expect(subject.status).not_to be_present
      expect(subject.error_msg).not_to be_present
    end

    it 'will not persist without manifest_url' do
      ingest = FactoryBot.build(:mars_ingest, manifest_url: nil)
      expect{ ingest.save! }.to raise_error(ActiveRecord::RecordInvalid, /is not an expected file type. Expected extensions are:/)
    end

    it 'validates the file type' do
      ingest_invalid_file_type = FactoryBot.build(:mars_ingest, manifest_url: 'https://s3-bos.wgbh.org/nehdigitization/manifest.xsls')
      expect { ingest_invalid_file_type.save! }.to raise_error(ActiveRecord::RecordInvalid, /is not an expected file type. Expected extensions are:/)
    end
  end

  describe '#validate_csv' do

    subject { FactoryBot.create(:mars_ingest) }

    it '#validate_headers' do
      subject.validate_headers
      expect(subject.mars_ingest_errors).to eq([])
    end

    it 'validates the presence of at least one row' do
    end

    it 'validates the presence of all required values' do
    end

    it 'validates that the values are in an acceptable format' do
    end
  end
end