class CreateMarsIngests < ActiveRecord::Migration[5.2]
  def change
    create_table :mars_ingests do |t|
      t.text :error_msg
      t.integer :item_count
      t.text :manifest_url, null: false

      t.timestamps
    end
  end
end
