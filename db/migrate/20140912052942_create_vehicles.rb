class CreateVehicles < ActiveRecord::Migration
  def change
    create_table :vehicles do |t|
      t.integer :uber_coordinate_id
      t.string :product
      t.integer :eta
      t.float :surge

      t.timestamps
    end
  end
end
