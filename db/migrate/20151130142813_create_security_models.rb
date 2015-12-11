class CreateSecurityModels < ActiveRecord::Migration
  def change
    create_table :result_agents do |t|
      t.string :result_agent_label
      t.text :json_str

      t.timestamps null: false
    end

    create_table :events do |t|
      t.string :event_source
      t.string :event_type
      t.string :event_name
      t.string :event_value

      t.timestamps null: false
    end

    create_table :results do |t|
      t.string :context_id
      t.string :user_id
      t.string :result

      t.timestamps null: false
    end

  end
end
