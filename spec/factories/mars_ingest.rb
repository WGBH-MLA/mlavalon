FactoryBot.define do
  factory :mars_ingest do
    submitter { FactoryBot.create(:manager) }
    # manifest_url { FactoryBot.build(:mars_manifest).url }
    # TODO: Remove item count; it should be a derived value.
    item_count { 500 }

    transient do
      size { 1 }
    end

    after(:build) do |mars_ingest, evaluator|
      # manifest_url is required, but setting it in after(:build) allows us to
      # specify a size for the manifest when creating the MarsIngest w/ factory.
      mars_ingest.manifest_url = FactoryBot.build(:mars_manifest, size: evaluator.size.to_i).url
    end
  end
end
