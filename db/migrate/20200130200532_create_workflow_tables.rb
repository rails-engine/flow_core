# frozen_string_literal: true

class CreateWorkflowTables < ActiveRecord::Migration[6.0]
  def change
    create_table :flow_core_workflows do |t|
      t.string :name, null: false
      t.string :tag

      t.integer :verified, null: false, default: false
      t.datetime :verified_at

      t.string :type

      t.timestamps
    end

    create_table :flow_core_places do |t|
      t.references :workflow, null: false, foreign_key: false

      t.string :name
      t.string :tag

      t.string :type

      t.timestamps
    end

    create_table :flow_core_transitions do |t|
      t.references :workflow, null: false, foreign_key: false

      t.string :name
      t.string :tag
      t.integer :output_token_create_strategy, null: false, default: 0, comment: "0-petri_net"
      t.integer :auto_finish_strategy, null: false, default: 0, comment: "0-disabled"

      t.timestamps
    end

    create_table :flow_core_arcs do |t|
      t.references :workflow, null: false, foreign_key: false
      t.references :transition, null: false, foreign_key: false
      t.references :place, null: false, foreign_key: false

      t.integer :direction, null: false, default: 0, comment: "0-in, 1-out"
      t.boolean :fallback_arc, null: false, default: false

      t.timestamps
    end

    create_table :flow_core_instances do |t|
      t.references :workflow, null: false, foreign_key: false

      t.string :tag, index: { unique: true }

      t.integer :stage, default: 0, comment: "0-created, 1-activated, 2-canceled, 3-finished, 4-terminated"
      t.datetime :activated_at
      t.datetime :finished_at
      t.datetime :canceled_at
      t.datetime :terminated_at

      t.string :terminate_reason

      t.text :payload

      t.string :type

      t.timestamps
    end

    create_table :flow_core_transition_triggers do |t|
      t.references :workflow, foreign_key: false
      t.references :transition, foreign_key: false

      t.text :configuration
      t.string :type

      t.timestamps
    end

    create_table :flow_core_arc_guards do |t|
      t.references :workflow, foreign_key: false
      t.references :arc, foreign_key: false

      t.text :configuration
      t.string :type

      t.timestamps
    end

    create_table :flow_core_tokens do |t|
      t.references :workflow, null: false, foreign_key: false
      t.references :instance, null: false, foreign_key: false
      t.references :place, null: false, foreign_key: false

      t.integer :stage, default: 0, comment: "0-free, 1-locked, 11-consumed, 12-terminated"
      t.datetime :locked_at
      t.datetime :consumed_at
      t.datetime :terminated_at

      t.references :created_by_task, foreign_key: false
      t.references :consumed_by_task, foreign_key: false

      t.boolean :task_created, null: false, default: false

      t.timestamps
    end

    create_table :flow_core_tasks do |t|
      t.references :workflow, null: false, foreign_key: false
      t.references :instance, null: false, foreign_key: false
      t.references :transition, null: false, foreign_key: false

      t.string :tag, index: { unique: true }

      t.references :created_by_token, foreign_key: false

      t.integer :stage, default: 0, comment: "0-created, 1-enabled, 11-finished, 12-terminated"
      t.datetime :enabled_at
      t.datetime :finished_at

      t.datetime :terminated_at
      t.string :terminate_reason

      t.datetime :errored_at
      t.datetime :rescued_at
      t.string :error_reason

      t.datetime :suspended_at
      t.datetime :resumed_at

      t.boolean :output_token_created, null: false, default: false

      t.references :executable, polymorphic: true

      t.text :payload

      t.timestamps
    end

    change_table :flow_core_places do |t|
      t.foreign_key :flow_core_workflows, column: :workflow_id
    end

    change_table :flow_core_transitions do |t|
      t.foreign_key :flow_core_workflows, column: :workflow_id
    end

    change_table :flow_core_arcs do |t|
      t.foreign_key :flow_core_workflows, column: :workflow_id
      t.foreign_key :flow_core_transitions, column: :transition_id
      t.foreign_key :flow_core_places, column: :place_id
    end

    change_table :flow_core_instances do |t|
      t.foreign_key :flow_core_workflows, column: :workflow_id
    end

    change_table :flow_core_transition_triggers do |t|
      t.foreign_key :flow_core_workflows, column: :workflow_id
      t.foreign_key :flow_core_transitions, column: :transition_id
    end

    change_table :flow_core_arc_guards do |t|
      t.foreign_key :flow_core_workflows, column: :workflow_id
      t.foreign_key :flow_core_arcs, column: :arc_id
    end

    change_table :flow_core_tokens do |t|
      t.foreign_key :flow_core_workflows, column: :workflow_id
      t.foreign_key :flow_core_instances, column: :instance_id
      t.foreign_key :flow_core_places, column: :place_id
      t.foreign_key :flow_core_tasks, column: :created_by_task_id
      t.foreign_key :flow_core_tasks, column: :consumed_by_task_id
    end

    change_table :flow_core_tasks do |t|
      t.foreign_key :flow_core_workflows, column: :workflow_id
      t.foreign_key :flow_core_instances, column: :instance_id
      t.foreign_key :flow_core_transitions, column: :transition_id
      t.foreign_key :flow_core_tokens, column: :created_by_token_id
    end
  end
end
