# frozen_string_literal: true

class LeaveWorkflow
  class EvaluateTask < ApprovalTask
    def leave
      @leave ||= begin
                   leave_id = task.instance.payload.fetch(:leave_id)
                   Leave.find(leave_id)
                 end
    end

    def render_in(view_context)
      view_context.render partial: "_leave_workflow/evaluate", locals: { task: self }
    end
  end
end
