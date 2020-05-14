require_relative '../support/mars_manifest_faker'

FactoryBot.define do
  factory :mars_manifest, class: MarsManifest do
    url { 'http://foo.edu/fake_manifest.csv'}

    transient do
      size { 1 }
      add_headers { nil }
      remove_headers { nil }
    end

    initialize_with do
      new(url: url)
    end

    after(:build) do |mars_manifest, evaluator|
      fake_manifest = MarsManifestFaker.new size: evaluator.size
      fake_manifest.add_headers(evaluator.add_headers) if evaluator.add_headers
      fake_manifest.remove_headers(evaluator.remove_headers) if evaluator.remove_headers
      allow_any_instance_of(MarsManifest).to receive(:csv).and_return CSV.parse(fake_manifest.to_s)
    end
  end
end
