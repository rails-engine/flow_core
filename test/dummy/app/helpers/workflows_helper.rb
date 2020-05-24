# frozen_string_literal: true

module WorkflowsHelper
  def forms_options_for_select(selected: nil)
    forms = FormKit::Form.all
    options_from_collection_for_select(forms, :id, :name, selected)
  end

  def trigger_types_options_for_select(selected: nil)
    types = FlowKit::TransitionTriggers.all_types
    options_for_select(types.map { |klass| [klass.model_name.human, klass.to_s] }, selected)
  end

  def callback_types_options_for_select(selected: nil)
    types = FlowKit::TransitionCallbacks.all_types
    options_for_select(types.map { |klass| [klass.model_name.human, klass.to_s] }, selected)
  end

  def guard_types_options_for_select(selected: nil)
    types = FlowKit::ArcGuards.all_types
    options_for_select(types.map { |klass| [klass.model_name.human, klass.to_s] }, selected)
  end

  def redirectable_steps_options_for_select(current_step)
    options_from_collection_for_select(current_step.redirectable_steps.sort_by(&:depth), :id, :name, current_step.redirect_to_step_id)
  end
end
