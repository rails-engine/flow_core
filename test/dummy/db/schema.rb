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

ActiveRecord::Schema.define(version: 2020_05_23_233225) do

  create_table "flow_core_arc_guards", force: :cascade do |t|
    t.integer "workflow_id"
    t.integer "arc_id"
    t.text "configuration"
    t.string "type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "pipeline_id"
    t.integer "branch_id"
    t.index ["arc_id"], name: "index_flow_core_arc_guards_on_arc_id"
    t.index ["branch_id"], name: "index_flow_core_arc_guards_on_branch_id"
    t.index ["pipeline_id"], name: "index_flow_core_arc_guards_on_pipeline_id"
    t.index ["workflow_id"], name: "index_flow_core_arc_guards_on_workflow_id"
  end

  create_table "flow_core_arcs", force: :cascade do |t|
    t.integer "workflow_id", null: false
    t.integer "transition_id", null: false
    t.integer "place_id", null: false
    t.integer "direction", default: 0, null: false
    t.boolean "fallback_arc", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["place_id"], name: "index_flow_core_arcs_on_place_id"
    t.index ["transition_id"], name: "index_flow_core_arcs_on_transition_id"
    t.index ["workflow_id"], name: "index_flow_core_arcs_on_workflow_id"
  end

  create_table "flow_core_branches", force: :cascade do |t|
    t.integer "pipeline_id", null: false
    t.integer "step_id", null: false
    t.string "name"
    t.boolean "fallback_branch", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["pipeline_id"], name: "index_flow_core_branches_on_pipeline_id"
    t.index ["step_id"], name: "index_flow_core_branches_on_step_id"
  end

  create_table "flow_core_instances", force: :cascade do |t|
    t.integer "workflow_id", null: false
    t.string "tag"
    t.integer "stage", default: 0
    t.datetime "activated_at"
    t.datetime "finished_at"
    t.datetime "canceled_at"
    t.datetime "terminated_at"
    t.string "terminate_reason"
    t.text "payload"
    t.string "type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "creator_type"
    t.integer "creator_id"
    t.integer "form_id"
    t.index ["creator_type", "creator_id"], name: "index_flow_core_instances_on_creator_type_and_creator_id"
    t.index ["form_id"], name: "index_flow_core_instances_on_form_id"
    t.index ["tag"], name: "index_flow_core_instances_on_tag", unique: true
    t.index ["workflow_id"], name: "index_flow_core_instances_on_workflow_id"
  end

  create_table "flow_core_pipelines", force: :cascade do |t|
    t.string "name", null: false
    t.string "type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "form_id"
    t.index ["form_id"], name: "index_flow_core_pipelines_on_form_id"
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

  create_table "flow_core_steps", force: :cascade do |t|
    t.integer "pipeline_id", null: false
    t.integer "branch_id"
    t.string "ancestry"
    t.integer "position", null: false
    t.string "name"
    t.string "type"
    t.boolean "verified", default: false, null: false
    t.integer "redirect_to_step_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["ancestry"], name: "index_flow_core_steps_on_ancestry"
    t.index ["branch_id"], name: "index_flow_core_steps_on_branch_id"
    t.index ["pipeline_id"], name: "index_flow_core_steps_on_pipeline_id"
    t.index ["redirect_to_step_id"], name: "index_flow_core_steps_on_redirect_to_step_id"
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

  create_table "flow_core_transition_triggers", force: :cascade do |t|
    t.integer "workflow_id"
    t.integer "transition_id"
    t.text "configuration"
    t.string "type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "pipeline_id"
    t.integer "step_id"
    t.integer "attached_form_id"
    t.integer "form_override_id"
    t.index ["attached_form_id"], name: "index_flow_core_transition_triggers_on_attached_form_id"
    t.index ["form_override_id"], name: "index_flow_core_transition_triggers_on_form_override_id"
    t.index ["pipeline_id"], name: "index_flow_core_transition_triggers_on_pipeline_id"
    t.index ["step_id"], name: "index_flow_core_transition_triggers_on_step_id"
    t.index ["transition_id"], name: "index_flow_core_transition_triggers_on_transition_id"
    t.index ["workflow_id"], name: "index_flow_core_transition_triggers_on_workflow_id"
  end

  create_table "flow_core_transitions", force: :cascade do |t|
    t.integer "workflow_id", null: false
    t.string "name"
    t.string "tag"
    t.integer "output_token_create_strategy", default: 0, null: false
    t.integer "auto_finish_strategy", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "generated_by_step_id"
    t.index ["generated_by_step_id"], name: "index_flow_core_transitions_on_generated_by_step_id"
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
    t.integer "generated_by_pipeline_id"
    t.integer "form_id"
    t.index ["form_id"], name: "index_flow_core_workflows_on_form_id"
    t.index ["generated_by_pipeline_id"], name: "index_flow_core_workflows_on_generated_by_pipeline_id"
  end

  create_table "flow_kit_assignee_candidates", force: :cascade do |t|
    t.string "assignable_type", null: false
    t.integer "assignable_id", null: false
    t.integer "trigger_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["assignable_type", "assignable_id"], name: "index_flow_kit_assignee_candidates_on_assignable"
    t.index ["trigger_id"], name: "index_flow_kit_assignee_candidates_on_trigger_id"
  end

  create_table "flow_kit_human_tasks", force: :cascade do |t|
    t.integer "workflow_id", null: false
    t.integer "instance_id", null: false
    t.integer "form_override_id"
    t.integer "attached_form_id"
    t.string "assignable_type"
    t.integer "assignable_id"
    t.string "status", null: false
    t.datetime "assigned_at"
    t.datetime "form_filled_at"
    t.datetime "finished_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["assignable_type", "assignable_id"], name: "index_form_kit_human_tasks_assignable"
    t.index ["attached_form_id"], name: "index_flow_kit_human_tasks_on_attached_form_id"
    t.index ["form_override_id"], name: "index_flow_kit_human_tasks_on_form_override_id"
    t.index ["instance_id"], name: "index_flow_kit_human_tasks_on_instance_id"
    t.index ["workflow_id"], name: "index_flow_kit_human_tasks_on_workflow_id"
  end

  create_table "form_kit_choices", force: :cascade do |t|
    t.integer "form_id", null: false
    t.integer "field_id", null: false
    t.text "label", null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["field_id"], name: "index_form_kit_choices_on_field_id"
    t.index ["form_id"], name: "index_form_kit_choices_on_form_id"
  end

  create_table "form_kit_field_overrides", force: :cascade do |t|
    t.integer "form_override_id", null: false
    t.integer "field_id", null: false
    t.integer "accessibility", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["field_id"], name: "index_form_kit_field_overrides_on_field_id"
    t.index ["form_override_id", "field_id"], name: "index_form_kit_field_overrides_on_form_field_id", unique: true
    t.index ["form_override_id"], name: "index_form_kit_field_overrides_on_form_override_id"
  end

  create_table "form_kit_fields", force: :cascade do |t|
    t.integer "form_id", null: false
    t.string "name"
    t.string "hint"
    t.string "key", null: false
    t.text "validations"
    t.text "options"
    t.integer "accessibility", null: false
    t.text "default_value"
    t.integer "position", default: 0, null: false
    t.string "type", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["form_id", "key"], name: "index_form_kit_fields_on_form_id_and_key", unique: true
    t.index ["form_id"], name: "index_form_kit_fields_on_form_id"
  end

  create_table "form_kit_form_overrides", force: :cascade do |t|
    t.integer "form_id", null: false
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["form_id"], name: "index_form_kit_form_overrides_on_form_id"
  end

  create_table "form_kit_forms", force: :cascade do |t|
    t.string "attachable_type"
    t.integer "attachable_id"
    t.string "name"
    t.string "key", null: false
    t.string "type", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["attachable_type", "attachable_id"], name: "index_form_kit_forms_on_attachable_type_and_attachable_id"
    t.index ["key"], name: "index_form_kit_forms_on_key", unique: true
  end

  create_table "notifications", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "task_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["task_id"], name: "index_notifications_on_task_id"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "flow_core_arc_guards", "flow_core_arcs", column: "arc_id"
  add_foreign_key "flow_core_arc_guards", "flow_core_branches", column: "branch_id"
  add_foreign_key "flow_core_arc_guards", "flow_core_pipelines", column: "pipeline_id"
  add_foreign_key "flow_core_arc_guards", "flow_core_workflows", column: "workflow_id"
  add_foreign_key "flow_core_arcs", "flow_core_places", column: "place_id"
  add_foreign_key "flow_core_arcs", "flow_core_transitions", column: "transition_id"
  add_foreign_key "flow_core_arcs", "flow_core_workflows", column: "workflow_id"
  add_foreign_key "flow_core_branches", "flow_core_pipelines", column: "pipeline_id"
  add_foreign_key "flow_core_branches", "flow_core_steps", column: "step_id"
  add_foreign_key "flow_core_instances", "flow_core_workflows", column: "workflow_id"
  add_foreign_key "flow_core_instances", "form_kit_forms", column: "form_id"
  add_foreign_key "flow_core_pipelines", "form_kit_forms", column: "form_id"
  add_foreign_key "flow_core_places", "flow_core_workflows", column: "workflow_id"
  add_foreign_key "flow_core_steps", "flow_core_branches", column: "branch_id"
  add_foreign_key "flow_core_steps", "flow_core_pipelines", column: "pipeline_id"
  add_foreign_key "flow_core_steps", "flow_core_steps", column: "redirect_to_step_id"
  add_foreign_key "flow_core_tasks", "flow_core_instances", column: "instance_id"
  add_foreign_key "flow_core_tasks", "flow_core_tokens", column: "created_by_token_id"
  add_foreign_key "flow_core_tasks", "flow_core_transitions", column: "transition_id"
  add_foreign_key "flow_core_tasks", "flow_core_workflows", column: "workflow_id"
  add_foreign_key "flow_core_tokens", "flow_core_instances", column: "instance_id"
  add_foreign_key "flow_core_tokens", "flow_core_places", column: "place_id"
  add_foreign_key "flow_core_tokens", "flow_core_tasks", column: "consumed_by_task_id"
  add_foreign_key "flow_core_tokens", "flow_core_tasks", column: "created_by_task_id"
  add_foreign_key "flow_core_tokens", "flow_core_workflows", column: "workflow_id"
  add_foreign_key "flow_core_transition_triggers", "flow_core_pipelines", column: "pipeline_id"
  add_foreign_key "flow_core_transition_triggers", "flow_core_steps", column: "step_id"
  add_foreign_key "flow_core_transition_triggers", "flow_core_transitions", column: "transition_id"
  add_foreign_key "flow_core_transition_triggers", "flow_core_workflows", column: "workflow_id"
  add_foreign_key "flow_core_transition_triggers", "form_kit_form_overrides", column: "form_override_id"
  add_foreign_key "flow_core_transition_triggers", "form_kit_forms", column: "attached_form_id"
  add_foreign_key "flow_core_transitions", "flow_core_steps", column: "generated_by_step_id"
  add_foreign_key "flow_core_transitions", "flow_core_workflows", column: "workflow_id"
  add_foreign_key "flow_core_workflows", "flow_core_pipelines", column: "generated_by_pipeline_id"
  add_foreign_key "flow_core_workflows", "form_kit_forms", column: "form_id"
  add_foreign_key "flow_kit_assignee_candidates", "flow_core_transition_triggers", column: "trigger_id"
  add_foreign_key "flow_kit_human_tasks", "flow_core_instances", column: "instance_id"
  add_foreign_key "flow_kit_human_tasks", "flow_core_workflows", column: "workflow_id"
  add_foreign_key "flow_kit_human_tasks", "form_kit_form_overrides", column: "form_override_id"
  add_foreign_key "flow_kit_human_tasks", "form_kit_forms", column: "attached_form_id"
  add_foreign_key "form_kit_choices", "form_kit_fields", column: "field_id"
  add_foreign_key "form_kit_choices", "form_kit_forms", column: "form_id"
  add_foreign_key "form_kit_field_overrides", "form_kit_fields", column: "field_id"
  add_foreign_key "form_kit_field_overrides", "form_kit_form_overrides", column: "form_override_id"
  add_foreign_key "form_kit_fields", "form_kit_forms", column: "form_id"
  add_foreign_key "form_kit_form_overrides", "form_kit_forms", column: "form_id"
  add_foreign_key "notifications", "users"
end
