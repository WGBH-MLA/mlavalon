require 'rails_helper'

RSpec.describe MarsIngestItem do

  # let(:unsaved_item) { FactoryBot.build(:mars_ingest_item) }
  let (:enqueued_item) { FactoryBot.create(:mars_ingest_item) }
  # let (:processing_item) { FactoryBot.create(:mars_ingest_item, :processing) }

  # let(:bad_payload) { %({ "not : "cool man"}) }

  # it 'is linked to a mars ingest' do
  #   expect(enqueued_item).mars_ingest.class.to eq(MarsIngest)
  # end

  describe 'validations' do
    it 'does accept valid statuses' do
      %w(enqueued processing failed succeeded).each do |status|
        enqueued_item.status = status
        expect(enqueued_item.valid?).to eq(true)
      end
    end

    it 'doesnt accept bogus status' do
      enqueued_item.status = 'straight_gumbo'
      expect{ enqueued_item.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
