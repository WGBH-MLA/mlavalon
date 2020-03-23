# Copyright 2011-2020, The Trustees of Indiana University and Northwestern
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
require 'active_encode/engine_adapters/no_transcode_adapter'


class NoTranscode < WatchedEncode
  self.engine_adapter = :no_transcode
  # before_create prepend: true do |encode|
  #   require('pry');binding.pry
  #   encode
  # end
  
  # persist this thing before and after create!
  around_create do |encode, block|
    master_file_id = encode.options[:master_file_id]
    model = ActiveEncode::EncodeRecord.find_or_initialize_by(global_id: encode_attributes[:global_id])
    master_file = MasterFile.find(master_file_id)
    master_file.workflow_id = encode.id
    master_file.encoder_classname = self.class.name
    master_file.save
  end

end
