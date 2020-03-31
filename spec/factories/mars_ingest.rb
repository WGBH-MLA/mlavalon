FactoryBot.define do
  factory :mars_ingest do
    manifest_url { 'https://s3-bos.wgbh.org/nehdigitization/manifest.csv' }
    item_count { 500 }
  end
end
