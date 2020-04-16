require 'rails_helper'

describe MarsIngestsController, type: :controller do
  # Fake Mars Manifest URL.
  let(:manifest_url) { 'http://foo.edu/manifest.csv' }

  # Fake Mars Manifest CSV response for the fake Manifest URL.
  let(:manifest_csv) { FactoryBot.build(:mars_manifest).csv }

  # Tie the fake URL and fake CSV response together.
  before do
    stub_request(:get, manifest_url).
           with(
             headers: {
         	  'Accept'=>'*/*',
         	  'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
         	  # 'Host'=>'s3-bos.wgbh.org',
         	  'User-Agent'=>'Ruby'
             }).
           to_return(status: 200, body: manifest_csv, headers: {})
  end

  before do
    # allow_any_instance_of(MarsIngest).to receive(:manifest_url_status).and_return(["200", "OK"])
    # allow_any_instance_of(MarsIngest).to receive(:valid_manifest_data?).and_return(true)
  end

  let!(:mars_ingest) { FactoryBot.create(:mars_ingest) }

  describe 'security' do
    context 'with non-authenticated user' do
      it "all routes should redirect to sign in" do
        expect(get :show, params: { id: mars_ingest.id }).to redirect_to(/#{Regexp.quote(new_user_session_path)}\?url=.*/)
        expect(get :index).to redirect_to(/#{Regexp.quote(new_user_session_path)}\?url=.*/)
      end
    end
  end

  describe "#index" do
    context 'gated discovery' do
      let!(:mars_ingest2) { FactoryBot.create(:mars_ingest) }
      let!(:mars_ingest3) { FactoryBot.create(:mars_ingest) }

      it "user should see all collections" do
        login_as :user
        get 'index'
        expect(response).to be_ok
        expect(assigns(:mars_ingests).count).to eql(3)
      end
    end

    context 'format json' do
      it 'returns json' do
        login_as :user
        get 'index', params: { format: :json }
        expect(response).to be_ok
        expect(response.content_type).to eq "application/json"
      end
    end
  end

  describe "#show" do
    it "should allow access to users" do
      login_as :user
      get 'show', params: { id: mars_ingest.id }
      expect(response).to be_ok
      expect(response).to render_template(:show)
    end

    context 'format json' do
      it 'returns json' do
        login_as :user
        get 'show', params: { id: mars_ingest.id, format: :json }
        expect(response).to be_ok
        expect(response.content_type).to eq "application/json"
        end
    end
  end

  describe 'POST #create', :focus do
    context 'with a URL to valid Mars Manifest' do
      xit 'creates the MarsIngest record' do
        expect { request }.to change { MarsIngest.count }.by(1)
      end
    end

    # context 'with an invalid MarsIngest model' do
    #   before do
    #     allow_any_instance_of(MarsIngest).to receive(:valid?).and_return false
    #     allow_any_instance_of(MarsIngest).to receive(:errors)
    #   end
    # end
  end
end
