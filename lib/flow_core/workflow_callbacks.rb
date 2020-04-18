# frozen_string_literal: true

module FlowCore
  module WorkflowCallbacks
    extend ActiveSupport::Concern

    def on_instance_cancel(_instance); end

    def on_instance_activate(_instance); end

    def on_instance_finish(_instance); end

    def on_instance_terminate(_instance); end

    def on_instance_task_enable(_task); end

    def on_instance_task_finish(_task); end

    def on_instance_task_terminate(_task); end

    def on_instance_task_errored(_task, _error); end

    def on_instance_task_rescue(_task); end

    def on_instance_task_suspend(_task); end

    def on_instance_task_resume(_task); end
  end
end
