class CreateJsonStores < ActiveRecord::Migration
  def change
    create_table :json_stores do |t|
      t.string :store_id
      t.string :uid
      t.text :json_str

      t.timestamps null: false
    end

    create_table :activities do |t|
      t.string :activity_type
      t.string :activity_name
      t.string :activity_value

      t.timestamps null: false
    end

  end
end
