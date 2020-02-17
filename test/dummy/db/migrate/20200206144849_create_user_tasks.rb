# frozen_string_literal: true

class CreateUserTasks < ActiveRecord::Migration[6.0]
  def change
    create_table :user_tasks do |t|
      t.string :workflow_tag
      t.string :transition_tag

      t.references :assignee, foreign_key: { to_table: "users" }
      t.boolean :approved
      t.text :comment
      t.boolean :finished, null: false, default: false

      t.string :type

      t.timestamps
    end
  end
end
