# frozen_string_literal: true

module TransitionCallbacks
  class Notification < FlowCore::TransitionCallback
    # Should in
    # :created, :enabled, :finished, :terminated,
    # :errored, :rescued :suspended, :resumed
    def on
      %i[enabled]
    end

    def _call(task)
      task.executable.assignee.notifications.create! task: task
    end
  end
end
