require 'csv_reader'
require 'rest-client'

filename = ARGV[0]
collection_id = ARGV[1]
raise 'that aint right' unless filename && collection_id

payloads = CSVReader.generate_payloads(filename, collection_id)

port = '80'
payloads.each do |payload|
  
  params = {
    method: :post,
    url: "http://localhost:#{port}/media_objects.json",
    payload: payload,
    headers: {
      content_type: :json,
      accept: :json,
      :'Avalon-Api-Key' => ENV['AVALON_API_KEY']
    },
    verify_ssl: false,
    timeout: 15
  }


  resp = RestClient::Request.execute(params)
end
