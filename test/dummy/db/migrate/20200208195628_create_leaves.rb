# frozen_string_literal: true

class CreateLeaves < ActiveRecord::Migration[6.0]
  def change
    create_table :leaves do |t|
      t.references :user, null: false, foreign_key: true
      t.date :start_date
      t.date :end_date
      t.string :reason
      t.string :stage
      t.references :workflow_instance, foreign_key: { to_table: "flow_core_instances" }

      t.timestamps
    end
  end
end
