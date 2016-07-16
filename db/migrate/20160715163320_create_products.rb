class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.integer :external_product_id, null: false
      t.integer :price, null: false
      t.string :name, null: false

      t.timestamps null: false
    end

    add_index :products, :external_product_id, unique: true
    add_index :products, :name
  end
end
