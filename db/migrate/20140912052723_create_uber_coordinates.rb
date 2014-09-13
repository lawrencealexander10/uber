class CreateUberCoordinates < ActiveRecord::Migration
  def change
    create_table :uber_coordinates do |t|
      t.string :location
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
  end
end
