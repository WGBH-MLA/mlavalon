class AddIngestStatus < ActiveRecord::Migration[5.2]
  def change
    add_column :mars_ingests, :status, :integer
  end
end
