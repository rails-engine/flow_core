# frozen_string_literal: true

module FlowCore
  module TransitionTriggerable
    extend ActiveSupport::Concern

    def on_verify(_transition, _violations); end

    def on_task_created(_task); end

    def on_task_enabled(_task); end

    def on_task_finished(_task); end

    def on_task_terminated(_task); end

    def on_task_suspended(_task); end

    def on_task_resumed(_task); end

    def on_task_errored(_task, error)
      raise error
    end

    def on_task_rescued(_task); end
  end
end
