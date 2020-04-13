class MartianWorker
  include Sidekiq::Worker

  def perform(row_payload)

    # transform to ingest api payload format

    # send ingest api request to avalon

    #report on success
      # mark green

    #report on failure
      # print errors!

  end
end
