# frozen_string_literal: true

class LeaveWorkflow
  class RequestTrigger < ::TransitionTriggers::HumanTask
    private

      def task_class
        LeaveWorkflow::RequestTask
      end
  end
end
