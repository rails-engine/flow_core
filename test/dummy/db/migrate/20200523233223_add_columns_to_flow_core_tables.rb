# frozen_string_literal: true

class AddColumnsToFlowCoreTables < ActiveRecord::Migration[6.0]
  def change
    change_table :flow_core_workflows do |t|
      t.references :form, foreign_key: { to_table: :form_kit_forms }
    end

    change_table :flow_core_pipelines do |t|
      t.references :form, foreign_key: { to_table: :form_kit_forms }
    end
  end
end
