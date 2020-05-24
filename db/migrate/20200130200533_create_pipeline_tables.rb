# frozen_string_literal: true

class CreatePipelineTables < ActiveRecord::Migration[6.0]
  def change
    create_table :flow_core_pipelines do |t|
      t.string :name, null: false
      t.string :type

      t.timestamps
    end

    create_table :flow_core_steps do |t|
      t.references :pipeline, null: false, foreign_key: { to_table: :flow_core_pipelines }

      t.string :ancestry, index: true
      t.integer :position, null: false

      t.string :name
      t.string :type
      t.boolean :verified, null: false, default: false

      t.references :redirect_to_step, foreign_key: { to_table: :flow_core_steps }

      t.timestamps
    end

    create_table :flow_core_branches do |t|
      t.references :pipeline, null: false, foreign_key: { to_table: :flow_core_pipelines }
      t.references :step, null: false, foreign_key: { to_table: :flow_core_steps }

      t.string :name
      t.boolean :fallback_branch, null: false, default: false

      t.timestamps
    end

    change_table :flow_core_steps do |t|
      t.references :branch, foreign_key: { to_table: :flow_core_branches }
    end

    change_table :flow_core_transition_triggers do |t|
      t.references :pipeline, foreign_key: { to_table: :flow_core_pipelines }
      t.references :step, foreign_key: { to_table: :flow_core_steps }
    end

    change_table :flow_core_transition_callbacks do |t|
      t.references :pipeline, foreign_key: { to_table: :flow_core_pipelines }
      t.references :step, foreign_key: { to_table: :flow_core_steps }
    end

    change_table :flow_core_arc_guards do |t|
      t.references :pipeline, foreign_key: { to_table: :flow_core_pipelines }
      t.references :branch, foreign_key: { to_table: :flow_core_branches }
    end

    change_table :flow_core_transitions do |t|
      t.references :generated_by_step, foreign_key: { to_table: :flow_core_steps }
    end

    change_table :flow_core_workflows do |t|
      t.references :generated_by_pipeline, foreign_key: { to_table: :flow_core_pipelines }
    end
  end
end
