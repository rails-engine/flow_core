# frozen_string_literal: true

class AddColumnsToFlowCoreTables < ActiveRecord::Migration[6.0]
  def change
    change_table :flow_core_workflows do |t|
      t.references :form, foreign_key: { to_table: :form_kit_forms }
    end

    change_table :flow_core_pipelines do |t|
      t.references :form, foreign_key: { to_table: :form_kit_forms }
    end

    change_table :flow_core_transition_triggers do |t|
      t.references :attached_form, foreign_key: { to_table: :form_kit_forms }
      t.references :form_override, foreign_key: { to_table: :form_kit_form_overrides }
    end
  end
end
