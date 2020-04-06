require 'rails_helper'

RSpec.describe MarsIngestItem do

  let(:unsaved_item) { FactoryBot.build(:mars_ingest_item) }
  let (:enqueued_item) { FactoryBot.create(:mars_ingest_item) }
  let (:processing_item) { FactoryBot.create(:mars_ingest_item, :processing) }

  let(:bad_payload) { %({ "not : "cool man"}) }

  # it 'is linked to a mars ingest' do
  #   expect(enqueued_item).mars_ingest.class.to eq(MarsIngest)
  # end

  it 'parses and saves a valid payload on #save' do
    expect(unsaved_item.row_payload).to eq("{}")
    unsaved_item.save
    expect(unsaved_item.valid?).to be(true)
    expect(unsaved_item.row_payload).to eq("{\"fields\":{\"title\":\"Explosions of Political Strife\",\"date_issued\":\"2000-01-01\",\"creator\":[null],\"alternative_title\":[null],\"translated_title\":[null],\"uniform_title\":[null],\"statement_of_responsibility\":null,\"date_created\":null,\"copyright_date\":null,\"abstract\":null,\"note\":[null],\"format\":null,\"resource_type\":[null],\"contributor\":[null],\"publisher\":[null],\"genre\":[null],\"subject\":[null],\"related_item_url\":[null],\"geographic_subject\":[null],\"temporal_subject\":[null],\"topical_subject\":[null],\"bibliographic_id\":null,\"language\":[null],\"terms_of_use\":null,\"table_of_contents\":[null],\"physical_description\":null,\"other_identifier\":[null],\"comment\":[null]},\"files\":[{\"files\":[{\"label\":\"frontline\",\"id\":\"6\",\"hls_url\":\"https://avalon.wgbh.org/hls/avalon/baby_eleanor.mp4/master.m3u8\",\"duration\":null,\"mime_type\":null,\"audio_bitrate\":null,\"audio_codec\":null,\"video_bitrate\":null,\"video_codec\":null,\"width\":null,\"height\":null}],\"label\":\"frontline_deleted_scenes_and_bloopers.mp4\",\"title\":\"frontline\",\"file_location\":null,\"file_checksum\":null,\"file_size\":null,\"duration\":null,\"display_aspect_ratio\":null,\"original_frame_size\":null,\"file_format\":null,\"date_digitized\":null,\"captions\":null,\"captions_type\":null,\"other_identifier\":null,\"comment\":null}],\"workflow_name\":\"avalon\",\"percent_complete\":\"100.0\",\"percent_succeeded\":\"100.0\",\"percent_failed\":\"0\",\"status_code\":\"COMPLETED\",\"collection_id\":null}")
  end

  describe 'validations' do
    it 'doesnt accept bogus status' do
      enqueued_item.status = 'straight_gumbo'
      expect{ enqueued_item.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end

    # doesnt validate when directly assigned....
    it 'doesnt accept bad payload' do

      enqueued_item.row_payload = bad_payload
      expect{ enqueued_item.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end  
end
