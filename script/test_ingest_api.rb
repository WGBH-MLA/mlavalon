require 'rest-client'

payload = {
  title: 'Test Ingested Object',
  date_issued: DateTime.now
}


params = {
  method: :post,
  url: 'http://localhost:3000/media_objects.json',
  payload: payload,
  headers: {
    content_type: :json,
    accept: :json,
    :'Avalon-Api-Key' => 'c9f6f12f3dbbf61f948d980692367c41ea0f5d3eed29e871a5d91a6de1b444ea8fbb8f372be79e015a3a8fe81c02fef9f1a7c589975ae1c333649804fe7f950e'
  },
  verify_ssl: false,
  timeout: 15
}

resp = RestClient::Request.execute(params)

puts resp
