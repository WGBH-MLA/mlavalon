FactoryBot.define do
  factory :mars_ingest_item do
    mars_ingest { FactoryBot.create(:mars_ingest) }
    status { 'enqueued' }
    
    # generate with real methods
    error { nil }
    row_payload { '{}' } #thatjsoon

    trait :processing do
      status { 'processing'}
      job_id { 'bip bip bip' }
    end
  end
end
