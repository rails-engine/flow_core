# frozen_string_literal: true

class LeaveWorkflow
  class EvaluateTrigger < ::TransitionTriggers::ApprovalTask
    private

      def task_class
        LeaveWorkflow::EvaluateTask
      end
  end
end
