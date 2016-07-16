class CreatePastPriceRecords < ActiveRecord::Migration
  def change
    create_table :past_price_records do |t|
      t.integer :product_id, null: false
      t.integer :price, null: false
      t.float :percentage_change, null: false

      t.timestamps null: false
    end
  end
end
