# frozen_string_literal: true

module FlowKit::TransitionCallbacks
  def self.all_types
    @all_types ||= [
      FlowKit::TransitionCallbacks::Notification
    ]
  end
end
