require 'rails_helper'

describe MarsIngest do
  before do
    MarsIngest.any_instance.stub(:manifest_url_status).and_return(["200", "OK"])
    MarsIngest.any_instance.stub(:valid_manifest_data?).and_return(true)
  end

  describe '#save' do
    subject { FactoryBot.build(:mars_ingest) }

    it 'persists with a manifest_url' do
      subject.save
      subject.reload
      expect(subject.manifest_url).to be_present
      expect(subject.item_count).to be_present
      expect(subject.error_msg).not_to be_present
    end

    it 'will not persist without manifest_url' do
      ingest = FactoryBot.build(:mars_ingest, manifest_url: nil)
      expect{ ingest.save! }.to raise_error(ActiveRecord::RecordInvalid, /is required/)
    end

    it 'validates the file type' do
      ingest_invalid_file_type = FactoryBot.build(:mars_ingest, manifest_url: 'https://s3-bos.wgbh.org/nehdigitization/manifest.xsls')
      expect { ingest_invalid_file_type.save! }.to raise_error(ActiveRecord::RecordInvalid, /is not an expected file type. Expected extensions are:/)
    end

    it 'returns expected error for unreachable manifest' do
      MarsIngest.any_instance.stub(:manifest_url_status).and_return(["404", "Not Found"])
      expect{ subject.save! }.to raise_error(ActiveRecord::RecordInvalid, /could not be reached and returns a status code of: 404, Not Found/)
    end

    it 'rescues and reports from a SocketError for unreachable manifest' do
      MarsIngest.any_instance.stub(:manifest_url_status).and_raise(SocketError)
      expect{ subject.save! }.to raise_error(ActiveRecord::RecordInvalid, /SocketError: failed to open connection to manifest_url/)
    end
  end
end