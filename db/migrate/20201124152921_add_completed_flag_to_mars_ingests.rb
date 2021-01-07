class AddCompletedFlagToMarsIngests < ActiveRecord::Migration[5.2]
  def change
    add_column :mars_ingests, :completed, :boolean, default: false
  end
end
