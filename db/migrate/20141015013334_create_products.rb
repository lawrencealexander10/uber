class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.integer :uber_coordinate_id
      t.string :product_id
      t.string :product_name

    end
  end
end
