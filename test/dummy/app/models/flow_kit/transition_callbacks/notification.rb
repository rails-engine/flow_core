# frozen_string_literal: true

module FlowKit::TransitionCallbacks
  class Notification < FlowCore::TransitionCallback
    # Should in
    # :created, :enabled, :finished, :terminated,
    # :errored, :rescued :suspended, :resumed
    def on
      %i[enabled]
    end

    def _call(task)
      return unless task.executable&.assignable

      task.executable.assignable.notifications.create! task: task
    end
  end
end
