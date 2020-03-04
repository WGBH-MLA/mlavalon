# require 'devise'
# require_relative '../config/initializers/devise'
require_relative '../config/environment'

unless User.where(email: 'woo@foo.edu').first
  puts "Didnt find woo, creating..."
  `rake avalon:user:create avalon_username=woo@foo.edu avalon_password=pppppp avalon_groups=administrator`

  # might need to run this from inside container
  `rake avalon:token:generate username=woo@foo.edu email=woo@foo.edu token=f97abb9fcb9d92638ce2fbb2571d4e9c7d6ddd80e59c60f287ad323e63886bc1509760c3e3b41b64cebadd8806b972bd324c0a24132dfa4641e35000674e7979`
else
  puts "Did find woo, and boy is that great"
end

unless Admin::Collection.where(name_ssi: "FRONTLINE").first
  puts "Didnt find FRONTLINE, creating!"
  `bundle exec ruby script/create_collections.rb`
else
  puts "Did find frontline..... Woo!"
end

# `cp -R spec/fixtures/batch_ingest/example_1/* /srv/avalon/dropbox`
