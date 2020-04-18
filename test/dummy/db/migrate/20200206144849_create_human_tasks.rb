# frozen_string_literal: true

class CreateHumanTasks < ActiveRecord::Migration[6.0]
  def change
    create_table :human_tasks do |t|
      t.string :workflow_tag
      t.string :transition_tag

      t.references :assignee, foreign_key: { to_table: "users" }
      t.datetime :finished_at

      t.string :type

      t.timestamps
    end
  end
end
