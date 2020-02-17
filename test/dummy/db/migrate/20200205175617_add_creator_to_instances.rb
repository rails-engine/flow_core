# frozen_string_literal: true

class AddCreatorToInstances < ActiveRecord::Migration[6.0]
  def change
    change_table :flow_core_instances do |t|
      t.references :creator, foreign_key: { to_table: "users" }
    end
  end
end
