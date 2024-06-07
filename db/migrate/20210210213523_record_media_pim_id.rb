class RecordMediaPimId < ActiveRecord::Migration[5.2]
  def change
    add_column :mars_ingest_items, :media_pim_id, :string
  end
end