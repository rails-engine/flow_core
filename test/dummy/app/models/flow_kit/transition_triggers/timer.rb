# frozen_string_literal: true

module FlowKit::TransitionTriggers
  class Timer < FlowCore::TransitionTrigger
    serialize :configuration, Configuration

    def configurable?
      true
    end

    def on_task_enable(task)
      TimerTaskJob.set(wait: configuration.countdown_in_seconds.seconds).perform_later(task.id)
    end
  end
end
