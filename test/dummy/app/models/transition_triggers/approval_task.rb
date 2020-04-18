# frozen_string_literal: true

module TransitionTriggers
  class ApprovalTask < HumanTask
    private

      def task_class
        ::ApprovalTask
      end
  end
end
