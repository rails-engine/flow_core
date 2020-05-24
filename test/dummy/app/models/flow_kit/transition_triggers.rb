# frozen_string_literal: true

module FlowKit::TransitionTriggers
  def self.all_types
    @all_types ||= [
      FlowKit::TransitionTriggers::HumanTask,
      FlowKit::TransitionTriggers::Timer
    ]
  end
end
