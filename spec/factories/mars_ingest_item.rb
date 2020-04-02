FactoryBot.define do
  factory :mars_ingest_item do
    # TODO turn on when avail
    # mars_ingest { FactoryBot.create(:mars_ingest) }
    status { 'enqueued' }
    
    # generate with real methods
    error { nil }

    csv_header_array { CSV.read('spec/fixtures/sample_csv_ingest/sample_csv_ingest_1.csv').first }
    csv_value_array { CSV.read('spec/fixtures/sample_csv_ingest/sample_csv_ingest_1.csv').last }
    # row_payload { '{}' } #thatjsoon

    trait :processing do
      status { 'processing'}
      job_id { 'bip bip bip' }
    end
  end
end
