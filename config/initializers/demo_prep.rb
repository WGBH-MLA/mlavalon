require 'fileutils'
require 'devise'

FileUtils.mkdir_p("/srv/avalon/dropbox")

# undefined method `devise' for User, may need to require 'environment'?
# unless User.where(email: 'woo@foo.edu')
#   `rake avalon:user:create avalon_username=woo@foo.edu avalon_password=pppppp avalon_groups=administrator`
# end

