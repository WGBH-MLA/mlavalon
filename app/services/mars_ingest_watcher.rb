class MarsIngestWatcher
  def self.run
    puts  "Hello!"
    key = get_manifest

    if key
      puts  "Got a manifest at #{key}, lets go!"
      url = move_manifest(key)
      run_manifest(url)
    else 
      puts  "It aint no manifests.. Bye!"
    end
  end

  def self.get_s3_client
    @client = Aws::S3::Client.new(
      region: 'us-east-1',
      access_key_id: ENV['WATCHFOLDER_S3_ACCESS'],
      secret_access_key: ENV['WATCHFOLDER_S3_SECRET']
    )
  end

  def self.get_manifest
    puts  "Let me check those manifests for you..."
    # list unprocessed s3 folder
    client = get_s3_client
    objs = client.list_objects({bucket: "mlavalon", prefix: "ingestion-inbox"})
    csv_key = objs.contents.map(&:key).find {|obj_key| obj_key != "ingestion-inbox/" }


    # if anything
      # ingest first one
      # url = "https://mlavalon.s3.amazonaws.com/export_2020-06-24_300_allQCd-httpsfix-SMALLCUT.csv"
      return nil unless csv_key
      puts  "I got #{csv_key}"
      # move ingest to processed s3 folder

    return csv_key
  end

  def self.move_manifest(input_key)
    # this moves a valid (saved as MarsIngest) csv from the 'inbox' folder to the 'outbox folder'

    client = get_s3_client
    # copy to new loc

    # destination = "https://mlavalon.s3.amazonaws.com/ingestion-outbox/" + File.basename(key)

    output_key = "ingestion-outbox/" + File.basename(input_key)
    puts  "Now copying #{input_key} to #{output_key}..."
    client.copy_object({bucket: "mlavalon", key: output_key, copy_source: "mlavalon/" + input_key})
    puts  "Checking for presence of #{output_key}"
    if client.head_object({bucket: "mlavalon", key: output_key})
      # 404 if not

      # need to make copy public so that ingest machinery can download the manifest
      puts  "Adding public acl to #{output_key}"
      client.put_object_acl({ acl: "public-read", bucket: "mlavalon", key: output_key })
      puts  "Now deleting #{input_key}..."
      client.delete_object({bucket: "mlavalon", key: input_key })

      # tis is the (now public) url we're actually going to hit for the ingest
      return output_key
    end

  end

  def self.run_manifest(key)
    user = User.where(email: "woo@foo.edu").first
    url = "https://mlavalon.s3.amazonaws.com/" + key

    mi = MarsIngest.new(manifest_url: url, submitter_id: user.id)
    if mi.save
      puts  "Ok, looks like the manifest was valid!"
      
      mi.mars_ingest_items.each do |mars_ingest_item|
        job_id = MarsIngestItemJob.perform_later(mars_ingest_item.id)
        puts ("Started MarsIngestItemJob with jid #{job_id} from MarsIngestItem #{mars_ingest_item.id}")
      end
    else
      require('pry');binding.pry
    end
  end

end