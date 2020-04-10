class AddMarsIngestItemTable < ActiveRecord::Migration[5.2]
  def change
    create_table :mars_ingest_items do |t|
      t.integer :mars_ingest_id
      t.string :row_payload
      t.string :error
      t.string :status
      t.timestamps
    end
  end
end
