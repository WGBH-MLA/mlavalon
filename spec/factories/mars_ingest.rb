FactoryBot.define do
  factory :mars_ingest do
    manifest_url { 'https://s3-bos.wgbh.org/nehdigitization/manifest.csv' }
    item_count { 500 }

    trait :valid do
      manifest_url { 'https://s3-bos.wgbh.org/nehdigitization/manifest.csv' }
      item_count { 500 }
      status { 'VALID' }
    end

    trait :invalid do
      manifest_url { 'https://s3-bos.wgbh.org/nehdigitization/manifest.csv' }
      item_count { 500 }
      status { 'INVALID' }
      error_msg { 'ERROR: Something is invalid.' }
    end
  end

end