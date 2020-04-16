FactoryBot.define do
  factory :mars_ingest do
    manifest_url { FactoryBot.build(:mars_manifest).url }
    item_count { 500 }
  end
end
