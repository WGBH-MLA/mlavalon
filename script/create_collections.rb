require 'rest-client'
require 'json'

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
