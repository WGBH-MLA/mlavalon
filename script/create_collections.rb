require_relative '../config/environment'
require 'rest-client'
require 'json'
require 'csv'

collection_names = ["FRONTLINE", "NOVA", "Ten O'Clock News", "Making Things Work", "Apollo 13: To the Edge and Back", "Think Twice", "Mystery of the Senses", "American Experience", "Boston Symphony Orchestra", "Masterpiece/Classic", "LEXINGTON DISABILITIES", "", "Crockett's Victory Garden", "Making Things Grow", "Evening At Pops", "Club, The", "Artist's Showcase", "Masterpiece Theatre", "New Voice, The", "Victory Garden", "Race To Save The Planet", "Say Brother", "The Group", "World, The", "French Chef, The", "WGBH Archives Historical Collection", "Note To You, A", "Et Cetera", "La Plaza", "Science Journal", "WGBH Journal", "Reading Aloud", "NHK Music Project", "Spider's Web"]

def send_request(params)
  JSON.parse(RestClient::Request.execute(params))
rescue => e
  puts "#{e.class}: #{e.message}"
  puts "API Response: #{e.response}" if e.respond_to? :response
end

def create_collection(collection_name)
  port = '3000'
  payload = { admin_collection: {} }
  collection_name = "No Collection" unless collection_name
  payload[:admin_collection][:name] = collection_name
  # payload[:admin_collection][:description] = row_data['Collection Description'] if row_data['Collection Description']
  # payload[:admin_collection][:unit] = row_data['Unit Name'] if row_data['Unit Name']
  payload[:admin_collection][:managers] = ["woo@foo.edu"]
  payload[:admin_collection][:unit] = "Default Unit"

  puts "Creating collection with payload = #{payload}"

  params = {
    method: :post,
    url: "http://0.0.0.0:#{port}/admin/collections.json",
    payload: payload,
    headers: {
      content_type: :json,
      accept: :json,
      # local dev value
      :'Avalon-Api-Key' => 'f97abb9fcb9d92638ce2fbb2571d4e9c7d6ddd80e59c60f287ad323e63886bc1509760c3e3b41b64cebadd8806b972bd324c0a24132dfa4641e35000674e7979'
    },
    verify_ssl: false,
    timeout: 15
  }

  send_request params
end

collection_names.each do |coll_name|
  puts "Boy I love #{coll_name}"
  create_collection(coll_name)
end




rows = CSV.read('./spec/fixtures/sample_csv_ingest/avalon_demo_batch_ingest_1.csv', {headers: true, encoding: 'UTF-8'})
split_rows = {}
rows.each do |row|
  row_hash = row.to_h
  series_name = row_hash.delete('Series Name')
  series_name = row_hash['Title'] unless series_name.to_s =~ /\w+/
  series_name = "ROGUES SHIT" unless series_name.to_s =~ /\w+/
  split_rows[series_name] ||= []
  split_rows[series_name] << row_hash
end

collection_dirs = Dir.glob("#{Settings.dropbox.path}/*").select { |d| File.directory? d }
puts "Found collection dirs... #{collection_dirs}"
split_rows.each do |series_name, rows|
  puts "Finding directory for series_name = #{series_name}"
  tr_series_name = series_name.tr(' ', '_')
  collection_dir = collection_dirs.select { |d| d =~ /#{tr_series_name}/ }.first
  if collection_dir
    filename = "#{tr_series_name}-#{Time.now.strftime('%Y-%m-%d')}.csv"
    filepath = File.join(collection_dir, filename)
    CSV.open(filepath, 'wb') do |csv|
      puts "Writing headrs to #{filename}: headers = #{rows.first.keys}"
      csv << ["Woo tang batch", "woo@foo.edu"]
      csv << rows.first.keys
      rows.each do |row|
        puts "Writing row to #{filename}: data = #{row.values}"
        csv << row.values
      end
    end
  else
    puts "ERROR: Could not find collection dir for series name of #{tr_series_name}!!!"
  end
end
