FactoryBot.define do
  factory :mars_ingest_item do
    # mars_ingest { FactoryBot.create(:mars_ingest) }
    status { 'enqueued' }
    
    # generate with real methods
    error { nil }
    csv_row_hash { CSV.read('spec/fixtures/sample_csv_ingest/sample_csv_ingest_1.csv', headers: true).first }
    

    # row_payload { '{}' } #thatjsoon

    trait :processing do
      status { 'processing'}
      job_id { 'bip bip bip' }
    end
  end
end
