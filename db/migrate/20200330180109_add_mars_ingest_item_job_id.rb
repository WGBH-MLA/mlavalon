class AddMarsIngestItemJobId < ActiveRecord::Migration[5.2]
  def change
    add_column :mars_ingest_items, :job_id, :string
  end
end
