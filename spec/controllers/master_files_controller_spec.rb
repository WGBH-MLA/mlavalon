# Copyright 2011-2015, The Trustees of Indiana University and Northwestern
#   University.  Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed
#   under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
#   CONDITIONS OF ANY KIND, either express or implied. See the License for the
#   specific language governing permissions and limitations under the License.
# ---  END LICENSE_HEADER BLOCK  ---

require 'rails_helper'

describe MasterFilesController do
  describe "#create" do
    let(:media_object) { FactoryGirl.create(:media_object) }
    let(:file) { double }
    before do
      login_user media_object.collection.managers.first
    end

    context "must provide a container id" do
      it "should fail if no container id provided" do
        request.env["HTTP_REFERER"] = "/"
        # @file = fixture_file_upload('/videoshort.mp4', 'video/mp4')

        expect { post :create, Filedata: [file], original: 'any'}.not_to change { MasterFile.count }
      end
    end

    context "cannot upload a file over the defined limit" do
      it "should provide a warning about the file size" do
        request.env["HTTP_REFERER"] = "/"

        # @file = fixture_file_upload('/videoshort.mp4', 'video/mp4')
        allow(file).to receive(:size).and_return(MasterFile::MAXIMUM_UPLOAD_SIZE + 2^21)

        expect { post :create, Filedata: [file], original: 'any', container_id: media_object.id}.not_to change { MasterFile.count }

        expect(flash[:error]).not_to be_nil
      end
    end

    context "must be a valid MIME type" do
      it "should recognize a video format" do
        file = fixture_file_upload('/videoshort.mp4', 'video/mp4')
        post :create,
          Filedata: [file],
          original: 'any',
          container_id: media_object.id

        master_file = media_object.reload.parts.first
        expect(master_file.file_format).to eq "Moving image"

        expect(flash[:errors]).to be_nil
      end

     it "should recognize an audio format" do
       file = fixture_file_upload('/jazz-performance.mp3', 'audio/mp3')
       post :create,
         Filedata: [file],
         original: 'any',
         container_id: media_object.id

       master_file = media_object.reload.parts.first
       expect(master_file.file_format).to eq "Sound"
     end

     it "should reject non audio/video format" do
       request.env["HTTP_REFERER"] = "/"

       file = fixture_file_upload('/public-domain-book.txt', 'application/json')

       expect { post :create, Filedata: [file], original: 'any', container_id: media_object.id }.not_to change { MasterFile.count }

       expect(flash[:error]).not_to be_nil
     end

     it "should recognize audio/video based on extension when MIMETYPE is of unknown format" do
       file = fixture_file_upload('/videoshort.mp4', 'application/octet-stream')

       post :create,
         Filedata: [file],
         original: 'any',
         container_id: media_object.id
       master_file = MasterFile.all.last
       expect(master_file.file_format).to eq "Moving image"

       expect(flash[:errors]).to be_nil
     end
    end

    context "should process file successfully" do
      it "should associate with a MediaObject" do
        file = fixture_file_upload('/videoshort.mp4', 'video/mp4')
        #Work-around for a Rails bug
        class << file
          attr_reader :tempfile
        end

        post :create, Filedata: [file], original: 'any', container_id: media_object.id

        master_file = MasterFile.all.last
        expect(media_object.reload.parts).to include master_file
        expect(master_file.mediaobject.id).to eq(media_object.id)

        expect(flash[:errors]).to be_nil
      end
      it "should associate a dropbox file" do
        skip
        allow_any_instance_of(Avalon::Dropbox).to receive(:find).and_return "spec/fixtures/videoshort.mp4"
        post :create, dropbox: [{id: 1}], original: 'any', container_id: media_object.id

        master_file = MasterFile.all.last
        media_object.reload
        expect(media_object.parts).to include master_file
        expect(master_file.mediaobject.id).to eq(media_object.id)

        expect(flash[:errors]).to be_nil
      end
      it "should not fail when associating with a published mediaobject" do
        media_object = FactoryGirl.create(:published_media_object)
        login_user media_object.collection.managers.first
        @file = fixture_file_upload('/videoshort.mp4', 'video/mp4')
        #Work-around for a Rails bug
        class << @file
          attr_reader :tempfile
        end

        post :create, Filedata: [@file], original: 'any', container_id: media_object.id

        master_file = MasterFile.all.last
        expect(media_object.reload.parts).to include master_file
        expect(master_file.mediaobject.id).to eq(media_object.id)

        expect(flash[:errors]).to be_nil
      end
    end
  end

  describe "#destroy" do
    let(:master_file) {FactoryGirl.create(:master_file)}
    before do
      disableCanCan!
    end

    context "should be deleted" do
      it "should no longer exist" do
        expect { post :destroy, id: master_file.id }.to change { MasterFile.count }.by(-1)
      end
    end

    context "should no longer be associated with its parent object" do
      it "should create then remove a file from a video object" do
        expect { post :destroy, id: master_file.id }.to change { MasterFile.count }.by(-1)
        expect(master_file.mediaobject.reload.parts).not_to include master_file
      end
    end
  end

  describe "#show" do
    let(:master_file) {FactoryGirl.create(:master_file, :with_media_object)}
    it "should redirect you to the media object page with the correct section" do
      get :show, id: master_file.id, t:'10'
      expect(response).to redirect_to("#{id_section_media_object_path(master_file.mediaobject.id, master_file.id)}?t=10")
    end
  end

  describe "#embed" do
    let(:master_file) {FactoryGirl.create(:master_file)}
    before do
      disableCanCan!
    end
    it "should render embed layout" do
      expect(get :embed, id: master_file.id).to render_template(layout: 'embed')
    end
  end

  describe "#set_frame" do
    subject(:mf){FactoryGirl.create(:master_file, :with_thumbnail, :with_media_object)}
    it "should redirect to sign in when not logged in" do
      expect(get :set_frame, id: mf.id ).to redirect_to new_user_session_path
    end
    it "should redirect to home when logged in and not authorized" do
      login_as :user
      expect(get :set_frame, id: mf.id ).to redirect_to root_path
    end
    context "authorized" do
      before { disableCanCan! }
      it "should redirect to edit_media_object" do
        expect(get :set_frame, id: mf.id, type: 'thumbnail', offset: '10').to redirect_to edit_media_object_path(mf.mediaobject_id, step: 'file-upload')
      end
      it "should return thumbnail" do
        expect_any_instance_of(MasterFile).to receive(:extract_still) {'fake image content'}
        get :set_frame, format: 'jpeg', id: mf.id, type: 'thumbnail', offset: '10'
        expect(response.body).to eq('fake image content')
        expect(response.headers['Content-Type']).to eq('image/jpeg')
      end
    end
  end

  describe "#get_frame" do
    subject(:mf){FactoryGirl.create(:master_file, :with_thumbnail, :with_media_object)}
    context "not authorized" do
      it "should redirect to sign in when not logged in" do
        expect(get :get_frame, id: mf.id ).to redirect_to new_user_session_path
      end
      it "should redirect to home when logged in and not authorized" do
        login_as :user
        expect(get :get_frame, id: mf.id ).to redirect_to root_path
      end
    end
    context "authorized" do
      before { disableCanCan! }
      it "should return thumbnail" do
        get :get_frame, id: mf.id, type: 'thumbnail', size: 'bar'
        expect(response.body).to eq('fake image content')
        expect(response.headers['Content-Type']).to eq('image/jpeg')
      end
      it "should return offset thumbnail" do
        expect_any_instance_of(MasterFile).to receive(:extract_still) {'fake image content'}
        get :get_frame, id: mf.id, type: 'thumbnail', size: 'bar', offset: '1'
        expect(response.body).to eq('fake image content')
        expect(response.headers['Content-Type']).to eq('image/jpeg')
      end
    end
  end

  describe "#attach_structure" do
    let(:master_file) { FactoryGirl.create(:master_file, :with_media_object) }

    before(:each) do
      disableCanCan!
      # populate the structuralMetadata datastream with an uploaded xml file
      @file = fixture_file_upload('/structure.xml', 'text/xml')
      post 'attach_structure', master_file: {structure: @file}, id: master_file.id
      master_file.reload
    end

    it "should populate structuralMetadata datastream with xml" do
      expect(master_file.structuralMetadata.xpath('//Item').length).to be(1)
      expect(master_file.structuralMetadata.valid?).to be true
      expect(flash[:errors]).to be_nil
      expect(flash[:notice]).to be_nil
    end
    it "should remove contents of structuralMetadata datastream" do
      # remove the contents of the datastream
      post 'attach_structure', id: master_file.id
      master_file.reload
      expect(master_file.structuralMetadata.new?).to be true
      expect(master_file.structuralMetadata.empty?).to be true
      expect(master_file.structuralMetadata.valid?).to be false
      expect(flash[:errors]).to be_nil
      expect(flash[:notice]).to be_nil
    end
  end
  describe "#attach_captions" do
    let(:master_file) { FactoryGirl.create(:master_file, :with_media_object) }

    before(:each) do
      disableCanCan!
    end

    it "should populate captions datastream with text" do
      # populate the captions datastream with an uploaded vtt file
      file = fixture_file_upload('/captions.vtt', 'text/vtt')
      post 'attach_captions', master_file: {captions: file}, id: master_file.id
      master_file.reload
      expect(master_file.captions.has_content?).to be_truthy
      expect(master_file.captions.label).to eq('captions.vtt')
      expect(master_file.captions.mime_type).to eq('text/vtt')
      expect(flash[:errors]).to be_nil
      expect(flash[:notice]).to be_nil
    end
    it "should remove contents of captions datastream" do
      # remove the contents of the datastream
      post 'attach_captions', id: master_file.id
      master_file.reload
      expect(master_file.captions.empty?).to be true
      expect(flash[:errors]).to be_nil
      expect(flash[:notice]).to be_nil
    end
  end
end