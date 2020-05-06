FactoryBot.define do
  factory :mars_ingest_item do
    mars_ingest
    status { 'enqueued' }

    # generate with real methods
    error { nil }

    # csv_header_array { CSV.read('spec/fixtures/sample_csv_ingest/sample_csv_ingest_1.csv').first }
    # csv_value_array { CSV.read('spec/fixtures/sample_csv_ingest/sample_csv_ingest_1.csv').last }

    trait :processing do
      status { 'processing'}
      job_id { 'bip bip bip' }
    end

    after(:build) do |mars_ingest_item, evaluator|
      # 
      # require "pry"; binding.pry
      #
      # mars_ingest_item.csv_header_array = evaluator.mars_ingest.send(:manifest).headers.clone
      # mars_ingest_item.csv_value_array = evaluator.mars_ingest.send(:manifest).rows.first
      #
      # require "pry"; binding.pry
      # mars_ingest_item

    end

  end
end
