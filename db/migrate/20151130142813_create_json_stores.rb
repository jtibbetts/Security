class CreateJsonStores < ActiveRecord::Migration
  def change
    create_table :json_stores do |t|
      t.string :store_id
      t.string :uid
      t.text :json_str

      t.timestamps null: false
    end
  end
end
