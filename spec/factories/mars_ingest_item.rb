FactoryBot.define do
  factory :mars_ingest_item do
    mars_ingest
    status { 'enqueued' }

    # generate with real methods
    error { nil }

    # placeholder so we can insert a bad payload
    row_payload { "{}" }

    csv_header_array { CSV.read('spec/fixtures/sample_csv_ingest/sample_csv_ingest_1.csv').first }
    csv_value_array { CSV.read('spec/fixtures/sample_csv_ingest/sample_csv_ingest_1.csv').last }

    trait :processing do
      status { 'processing'}
      job_id { 'bip bip bip' }
    end

  end
end
