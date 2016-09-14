class CreateShops < ActiveRecord::Migration
  def change
    create_table :shops do |t|
      t.string :shop_id
      t.string :shop_name
      t.float :rankin
      t.string :popular_product
      t.string :popular_product_url

      t.timestamps null: false
    end
  end
end
