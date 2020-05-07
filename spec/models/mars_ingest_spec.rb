require 'rails_helper'

describe MarsIngest do

  describe 'validation' do
    subject { FactoryBot.build(:mars_ingest) }

    # Verify subject valid before hand and test validity after specific changes.
    before { expect(subject).to be_valid }

    it 'validates the presence of :manifest_url' do
      subject.manifest_url = nil
      subject.validate
      expect(subject).to have_error_on :manifest_url, /required/
    end

    context 'when the manifest is invalid, with errors' do
      let(:manifest_errors) {
        { foo: ["Alpha", "Bravo"], bar: ["Charlie", "Delta"] }
      }

      before do
        allow(subject.manifest).to receive(:errors).and_return(manifest_errors)
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
