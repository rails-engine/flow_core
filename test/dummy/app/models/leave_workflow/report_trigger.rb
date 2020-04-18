# frozen_string_literal: true

class LeaveWorkflow
  class ReportTrigger < ::TransitionTriggers::HumanTask
    private

      def task_class
        LeaveWorkflow::ReportTask
      end
  end
end
