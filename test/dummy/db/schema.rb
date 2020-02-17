# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_02_16_160434) do

  create_table "flow_core_arc_guards", force: :cascade do |t|
    t.integer "workflow_id", null: false
    t.integer "arc_id", null: false
    t.text "configuration"
    t.string "type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["arc_id"], name: "index_flow_core_arc_guards_on_arc_id"
    t.index ["workflow_id"], name: "index_flow_core_arc_guards_on_workflow_id"
  end

  create_table "flow_core_arcs", force: :cascade do |t|
    t.integer "workflow_id", null: false
    t.integer "transition_id", null: false
    t.integer "place_id", null: false
    t.integer "direction", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["place_id"], name: "index_flow_core_arcs_on_place_id"
    t.index ["transition_id"], name: "index_flow_core_arcs_on_transition_id"
    t.index ["workflow_id"], name: "index_flow_core_arcs_on_workflow_id"
  end

  create_table "flow_core_instances", force: :cascade do |t|
    t.integer "workflow_id", null: false
    t.string "tag"
    t.integer "stage", default: 0
    t.datetime "activated_at"
    t.datetime "finished_at"
    t.datetime "canceled_at"
    t.datetime "terminated_at"
    t.string "terminated_reason"
    t.datetime "errored_at"
    t.datetime "rescued_at"
    t.datetime "suspended_at"
    t.datetime "resumed_at"
    t.text "payload"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "creator_id"
    t.index ["creator_id"], name: "index_flow_core_instances_on_creator_id"
    t.index ["tag"], name: "index_flow_core_instances_on_tag", unique: true
    t.index ["workflow_id"], name: "index_flow_core_instances_on_workflow_id"
  end

  create_table "flow_core_places", force: :cascade do |t|
    t.integer "workflow_id", null: false
    t.string "name"
    t.string "tag"
    t.string "type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["workflow_id"], name: "index_flow_core_places_on_workflow_id"
  end

  create_table "flow_core_tasks", force: :cascade do |t|
    t.integer "workflow_id", null: false
    t.integer "instance_id", null: false
    t.integer "transition_id", null: false
    t.string "tag"
    t.integer "created_by_token_id"
    t.integer "stage", default: 0
    t.datetime "enabled_at"
    t.datetime "finished_at"
    t.datetime "terminated_at"
    t.string "terminate_reason"
    t.datetime "errored_at"
    t.datetime "rescued_at"
    t.string "error_reason"
    t.datetime "suspended_at"
    t.datetime "resumed_at"
    t.boolean "output_token_created", default: false, null: false
    t.string "executable_type"
    t.integer "executable_id"
    t.text "payload"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["created_by_token_id"], name: "index_flow_core_tasks_on_created_by_token_id"
    t.index ["executable_type", "executable_id"], name: "index_flow_core_tasks_on_executable_type_and_executable_id"
    t.index ["instance_id"], name: "index_flow_core_tasks_on_instance_id"
    t.index ["tag"], name: "index_flow_core_tasks_on_tag", unique: true
    t.index ["transition_id"], name: "index_flow_core_tasks_on_transition_id"
    t.index ["workflow_id"], name: "index_flow_core_tasks_on_workflow_id"
  end

  create_table "flow_core_tokens", force: :cascade do |t|
    t.integer "workflow_id", null: false
    t.integer "instance_id", null: false
    t.integer "place_id", null: false
    t.integer "stage", default: 0
    t.datetime "locked_at"
    t.datetime "consumed_at"
    t.datetime "terminated_at"
    t.integer "created_by_task_id"
    t.integer "consumed_by_task_id"
    t.boolean "task_created", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["consumed_by_task_id"], name: "index_flow_core_tokens_on_consumed_by_task_id"
    t.index ["created_by_task_id"], name: "index_flow_core_tokens_on_created_by_task_id"
    t.index ["instance_id"], name: "index_flow_core_tokens_on_instance_id"
    t.index ["place_id"], name: "index_flow_core_tokens_on_place_id"
    t.index ["workflow_id"], name: "index_flow_core_tokens_on_workflow_id"
  end

  create_table "flow_core_transition_callbacks", force: :cascade do |t|
    t.integer "workflow_id", null: false
    t.integer "transition_id", null: false
    t.string "configuration"
    t.string "type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["transition_id"], name: "index_flow_core_transition_callbacks_on_transition_id"
    t.index ["workflow_id"], name: "index_flow_core_transition_callbacks_on_workflow_id"
  end

  create_table "flow_core_transition_triggers", force: :cascade do |t|
    t.integer "workflow_id", null: false
    t.integer "transition_id", null: false
    t.text "configuration"
    t.string "type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["transition_id"], name: "index_flow_core_transition_triggers_on_transition_id"
    t.index ["workflow_id"], name: "index_flow_core_transition_triggers_on_workflow_id"
  end

  create_table "flow_core_transitions", force: :cascade do |t|
    t.integer "workflow_id", null: false
    t.string "name"
    t.string "tag"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["workflow_id"], name: "index_flow_core_transitions_on_workflow_id"
  end

  create_table "flow_core_workflows", force: :cascade do |t|
    t.string "name", null: false
    t.string "tag"
    t.integer "verified", default: 0, null: false
    t.datetime "verified_at"
    t.string "type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "leaves", force: :cascade do |t|
    t.integer "user_id", null: false
    t.date "start_date"
    t.date "end_date"
    t.string "reason"
    t.string "stage"
    t.integer "workflow_instance_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_leaves_on_user_id"
    t.index ["workflow_instance_id"], name: "index_leaves_on_workflow_instance_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "task_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["task_id"], name: "index_notifications_on_task_id"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "user_tasks", force: :cascade do |t|
    t.string "workflow_tag"
    t.string "transition_tag"
    t.integer "assignee_id"
    t.boolean "approved"
    t.text "comment"
    t.boolean "finished", default: false, null: false
    t.string "type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["assignee_id"], name: "index_user_tasks_on_assignee_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "flow_core_arc_guards", "flow_core_arcs", column: "arc_id"
  add_foreign_key "flow_core_arc_guards", "flow_core_workflows", column: "workflow_id"
  add_foreign_key "flow_core_arcs", "flow_core_places", column: "place_id"
  add_foreign_key "flow_core_arcs", "flow_core_transitions", column: "transition_id"
  add_foreign_key "flow_core_arcs", "flow_core_workflows", column: "workflow_id"
  add_foreign_key "flow_core_instances", "flow_core_workflows", column: "workflow_id"
  add_foreign_key "flow_core_instances", "users", column: "creator_id"
  add_foreign_key "flow_core_places", "flow_core_workflows", column: "workflow_id"
  add_foreign_key "flow_core_tasks", "flow_core_instances", column: "instance_id"
  add_foreign_key "flow_core_tasks", "flow_core_tokens", column: "created_by_token_id"
  add_foreign_key "flow_core_tasks", "flow_core_transitions", column: "transition_id"
  add_foreign_key "flow_core_tasks", "flow_core_workflows", column: "workflow_id"
  add_foreign_key "flow_core_tokens", "flow_core_instances", column: "instance_id"
  add_foreign_key "flow_core_tokens", "flow_core_places", column: "place_id"
  add_foreign_key "flow_core_tokens", "flow_core_tasks", column: "consumed_by_task_id"
  add_foreign_key "flow_core_tokens", "flow_core_tasks", column: "created_by_task_id"
  add_foreign_key "flow_core_tokens", "flow_core_workflows", column: "workflow_id"
  add_foreign_key "flow_core_transition_callbacks", "flow_core_transitions", column: "transition_id"
  add_foreign_key "flow_core_transition_callbacks", "flow_core_workflows", column: "workflow_id"
  add_foreign_key "flow_core_transition_triggers", "flow_core_transitions", column: "transition_id"
  add_foreign_key "flow_core_transition_triggers", "flow_core_workflows", column: "workflow_id"
  add_foreign_key "flow_core_transitions", "flow_core_workflows", column: "workflow_id"
  add_foreign_key "leaves", "flow_core_instances", column: "workflow_instance_id"
  add_foreign_key "leaves", "users"
  add_foreign_key "notifications", "users"
  add_foreign_key "user_tasks", "users", column: "assignee_id"
end
