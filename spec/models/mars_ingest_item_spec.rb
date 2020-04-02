require 'rails_helper'

RSpec.describe MarsIngestItem do

  let(:unsaved_item) { FactoryBot.build(:mars_ingest_item) }

  let (:enqueued_item) { FactoryBot.create(:mars_ingest_item) }
  let (:processing_item) { FactoryBot.create(:mars_ingest_item, :processing) }

  let(:bad_payload) { "{;;what:}" }

  # let(:mapped_payload) {
  #   # big ol hash
  # }

  it 'is linked to a mars ingest' do
    expect(enqueued_item).mars_ingest.class.to eq(MarsIngest)
  end

  it 'parses and saves a valid payload on #save' do
    unsaved_item.save
    # expect(unsaved_item.payload).to eq()
  end

  it 'returns me a nice-a payload ' do
    expect(enqueued_item).payload
  end
  


  describe 'validations' do
    it 'doesnt accept bogus status' do
      enqueued_item.status = 'straight_gumbo'
      expect(enqueued_item.save).to raise_error(InvalidThingyError)
    end
    
    it 'doesnt accept bad payload' do
      enqueued_item.row_payload = bad_payload
      expect(enqueued_item.save).to raise_error(InvalidThingyError)
    end
  end  
end
