require 'rails_helper'

describe MarsIngestsController, type: :controller do
  before do
    MarsIngest.any_instance.stub(:manifest_url_status).and_return(["200", "OK"])
    MarsIngest.any_instance.stub(:valid_manifest_data?).and_return(true)
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
end
