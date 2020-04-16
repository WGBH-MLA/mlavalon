FactoryBot.define do
  factory :mars_manifest, class: MarsManifest do
    url { 'http://foo.edu/fake_manifest.csv'}

    transient do
      raw_csv { MarsManifestFaker.new.to_s }
    end

    initialize_with do
      new(url: url)
    end

    after(:build) do |mars_manifest, evaluator|
      # Mock the URL to return the value given for the CSV.
      WebMock.stub_request(:get, mars_manifest.url).
              with(
                headers: {
               	  'Accept' => '*/*',
               	  'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
               	  'Host' => URI.parse(mars_manifest.url).host,
               	  'User-Agent' => 'Ruby'
                }).
              to_return(status: 200, body: evaluator.raw_csv, headers: {})
    end
  end
end
