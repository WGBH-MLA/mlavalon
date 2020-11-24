class AddCompletedFlagToMarsIngests < ActiveRecord::Migration[5.2]
  def change
    add_column :completed, :mars_ingests, :boolean, default: false
  end
end
