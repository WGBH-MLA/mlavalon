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

      # Mock the URL to return the value given for the CSV.
      WebMock.stub_request(:get, mars_manifest.url).
              with(
                headers: {
               	  'Accept' => '*/*',
               	  'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
               	  'Host' => URI.parse(mars_manifest.url).host,
               	  'User-Agent' => 'Ruby'
                }).
              to_return(status: 200, body: fake_manifest.to_s, headers: {})
    end
  end
end
