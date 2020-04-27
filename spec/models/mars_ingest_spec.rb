require 'rails_helper'

describe MarsIngest do

  describe 'validation' do
    it 'validates the presence of :manifest_url' do
      mars_ingest = FactoryBot.build(:mars_ingest, manifest_url: nil)
      mars_ingest.validate
      expect(mars_ingest.errors[:manifest_url].first).to match /required/
    end

    context 'when the manifest is invalid, with errors' do
      let(:manifest) { instance_double(MarsManifest) }
      let(:manifest_errors) {
        { foo: ["Alpha", "Bravo"], bar: ["Charlie", "Delta"] }
      }

      before do
        # Mock the "nearest edge" within #validate_manifest.
        allow(manifest).to receive(:valid?).and_return(false)
        allow(manifest).to receive(:errors).and_return(manifest_errors)
        allow(subject).to receive(:manifest).and_return(manifest)

        # Call the method under test.
        subject.validate
      end

      it 'adds all errors from the manifest onto the :manifest error' do
        manifest_errors.values.each do |error_msgs|
          expect(subject.errors[:manifest]).to include error_msgs
        end
      end
    end
  end
end
