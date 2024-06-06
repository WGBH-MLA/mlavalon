class CreateMarsIngestFailures < ActiveRecord::Migration[5.2]
  def change
    create_table :mars_ingest_failures do |t|
      t.text :error_text
      t.text :manifest_url
      t.timestamps
    end
  end
end
