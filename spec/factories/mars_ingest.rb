FactoryBot.define do
  factory :mars_ingest do
    submitter { FactoryBot.create(:manager) }
    manifest_url { FactoryBot.build(:mars_manifest).url }
    item_count { 500 }
  end
end
