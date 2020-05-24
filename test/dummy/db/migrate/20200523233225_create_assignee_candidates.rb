# frozen_string_literal: true

class CreateAssigneeCandidates < ActiveRecord::Migration[6.0]
  def change
    create_table :flow_kit_assignee_candidates do |t|
      t.references :assignable, polymorphic: true, null: false, index: { name: "index_flow_kit_assignee_candidates_on_assignable" }
      t.references :trigger, null: false, foreign_key: { to_table: :flow_core_transition_triggers }

      t.timestamps
    end
  end
end
