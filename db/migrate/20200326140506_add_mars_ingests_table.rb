class AddMarsIngestsTable < ActiveRecord::Migration[5.2]
  def change
    create_table :mars_ingests do |t|
      t.string :input_filename
      t.integer :number_of_items

      t.string :error
      t.string :status

      t.timestamps
    end
  end
end
