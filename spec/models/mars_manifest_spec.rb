require 'rails_helper'
require 'mars_manifest'

RSpec.describe MarsManifest do
  subject { described_class.new url: url }
  let(:url_response_body) { '' }

  describe '#validate' do
    context 'when created with no URL' do
      let(:url) { nil }
      before { subject.validate }
      it { is_expected.to have_errors_on(:url) }
    end

    context 'when created with an invalid URL' do
      let(:url) { 'not a url' }
      before { subject.validate }
      it { is_expected.to have_errors_on(:url) }
    end

    context 'when created with a valid URL' do
      let(:url) { 'http://example.com' }
      before do
        # Now that we're dealing with a valid URL, stub the request to it.
        stub_request(:get, url).
          with(
            headers: {
              'Accept'=>'*/*',
              'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'User-Agent'=>'Ruby'
            }
          ).
          to_return(status: 200, body: url_response_body, headers: {})

        # Call MarsManifest#validate before each example.
        subject.validate
      end

      context 'and when the URL resolves to non-CSV data' do
        let(:url_response_body) { File.read('./app/assets/images/favicon.ico') }
        it { is_expected.to have_errors_on(:csv) }
      end

      context 'and when the URL resolves to actual CSV data' do
        context 'and when the CSV data has the correct headers' do
          let(:subject) { FactoryBot.build(:mars_manifest) }
          it { is_expected.not_to have_errors_on(:headers) }
        end

        context 'and when CSV has unrecognized headers' do
          let(:subject) { FactoryBot.build(:mars_manifest, add_headers: "cheese") }
          it { is_expected.to have_error_on(:headers, /cheese/) }
        end
      end
    end
  end
end
