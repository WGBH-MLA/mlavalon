require 'rails_helper'

describe MarsIngestItem, type: :model do
  let (:enqueued_item) { Factory.create(:mars_ingest_item) }
  let (:processing_item) { Factory.create(:mars_ingest_item, :processing) }

  let(:bad_payload) { "{;;what:}" }

  let(:mapped_payload) {
    # big ol hash
  }

  it 'is linked to a mars ingest' do
    expect(enqueued_item).mars_ingest.class.to eq(MarsIngest)
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
      enqueued_item.payload = bad_payload
      expect(enqueued_item.save).to raise_error(InvalidThingyError)
    end
  end  
end
