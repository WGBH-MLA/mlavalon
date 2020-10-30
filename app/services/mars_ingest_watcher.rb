class MarsIngestWatcher
  def self.run
    Rails.logger.info "Hello!"
    url = get_manifest

    if url
      run_manifest(url)
    end
  end

  def self.get_manifest
    Rails.logger.info "Let me check those manifests for you..."
    # list unprocessed s3 folder

    # if anything
      # ingest first one
      url = "https://mlavalon.s3.amazonaws.com/export_2020-06-24_300_allQCd-httpsfix-SMALLCUT.csv"
      Rails.logger.info "I got #{url}"
      # move ingest to processed s3 folder

    return url
  end

  def self.run_manifest(url)
    user = User.where(email: "woo@foo.edu").first
    mi = MarsIngest.new(manifest_url: url, submitter_id: user.id)
    if mi.save
      Rails.logger.info "Ok, looks like the manifest was valid!"
      
      mi.mars_ingest_items.each do |mars_ingest_item|
        job_id = MarsIngestItemJob.perform_later(mars_ingest_item.id)
        Rails.logger.info("Started MarsIngestItemJob with jid #{job_id} from MarsIngestItem #{mars_ingest_item.id}")
      end
    else
      require('pry');binding.pry
    end
  end

end