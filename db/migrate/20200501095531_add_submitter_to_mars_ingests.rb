class AddSubmitterToMarsIngests < ActiveRecord::Migration[5.2]
  def change
    add_reference :mars_ingests, :submitter, foreign_key: { to_table: :users }
  end
end
