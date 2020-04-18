# frozen_string_literal: true

class LeaveWorkflow
  class ReportTask < HumanTask
    def leave
      @leave ||= begin
                   leave_id = task.instance.payload.fetch(:leave_id)
                   Leave.find(leave_id)
                 end
    end

    def render_in(view_context)
      view_context.render partial: "_leave_workflow/report", locals: { task: self }
    end

    PAYLOAD_ATTRIBUTES = %w[comment].freeze
    def set_payload(params: nil, attributes: nil)
      unless params || attributes
        raise ArgumentError, "Must provide `params` or `attributes`"
      end

      if params
        payload.merge! params.permit(*PAYLOAD_ATTRIBUTES)
      else
        payload.merge! attributes.slice(*PAYLOAD_ATTRIBUTES)
      end
    end
  end
end
