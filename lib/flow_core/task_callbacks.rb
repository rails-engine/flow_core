# frozen_string_literal: true

module FlowCore
  module TaskCallbacks
    extend ActiveSupport::Concern

    def on_task_enable(_task); end

    def on_task_finish(_task); end

    def on_task_terminate(_task); end

    def on_task_suspend(_task); end

    def on_task_resume(_task); end

    def on_task_errored(_task, _error); end

    def on_task_rescue(_task); end
  end
end
