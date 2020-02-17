# frozen_string_literal: true

module FlowCore
  module TaskExecutable
    extend ActiveSupport::Concern

    included do
      has_one :task, as: :executable, required: true, class_name: "FlowCore::Task"
      has_one :instance, through: :task, class_name: "FlowCore::Instance"
      has_one :transition, -> { readonly }, through: :task, class_name: "FlowCore::Transition"

      after_save :notify_workflow_task_finished!, if: :implicit_notify_workflow_task_finished
    end

    # For automatic task
    def run!
      raise NotImplementedError
    end

    def finished?
      raise NotImplementedError
    end

    def implicit_notify_workflow_task_finished
      true
    end

    protected

      def notify_workflow_task_finished!
        task.finish! if finished?
      end
  end
end
