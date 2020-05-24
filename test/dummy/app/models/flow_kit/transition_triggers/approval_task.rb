# frozen_string_literal: true

module FlowKit::TransitionTriggers
  class ApprovalTask < HumanTask
    private

      def task_class
        ::ApprovalTask
      end
  end
end
