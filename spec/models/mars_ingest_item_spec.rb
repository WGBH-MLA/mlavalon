require 'rails_helper'

RSpec.describe MarsIngestItem do
  # Note: use :mars_ingest factory rather than :mars_ingest_item factory.
  # It's more overhead, but less confusing than having to mock all the
  # dependencies.
  subject { FactoryBot.create(:mars_ingest).mars_ingest_items.first }

  describe 'validations' do
    # Verify we're valid before hand, then test validity of specific changes.
    before { expect(subject).to be_valid }

    it 'does accept valid statuses' do
      %w(unprocessed enqueued processing failed succeeded).each do |status|
        subject.status = status
        expect(subject).to be_valid
      end
    end

    it 'doesnt accept bogus status' do
      subject.status = 'straight_gumbo'
      expect(subject).not_to be_valid
    end

    it 'row_payload requires a "collection_id" key' do
      subject.row_payload.delete('collection_id')
      expect(subject).not_to be_valid
    end

    it 'row_payload requires a "title" key' do
      subject.row_payload.delete('title')
      expect(subject).not_to be_valid
    end

    it 'row_payload requires a "files" key' do
      subject.row_payload.delete('files')
      expect(subject).not_to be_valid
    end
  end
end
