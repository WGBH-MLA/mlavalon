class MarsIngest < ActiveRecord::Base
  def start_ingest
    MartianWorker.perform_async()
  end
  

end