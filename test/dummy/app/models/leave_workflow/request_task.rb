# frozen_string_literal: true

class LeaveWorkflow
  class RequestTask < HumanTask
    def leave
      @leave ||= begin
                   leave_id = task.instance.payload.fetch(:leave_id)
                   Leave.find(leave_id)
                 end
    end

    delegate :start_date, :end_date, :reason, to: :leave

    LEAVE_ATTRIBUTES = %w[start_date end_date reason].freeze
    PAYLOAD_ATTRIBUTES = (%w[comment discard] + LEAVE_ATTRIBUTES).freeze
    def set_payload(params: nil, attributes: nil)
      unless params || attributes
        raise ArgumentError, "Must provide `params` or `attributes`"
      end

      if params
        payload.merge! params.permit(*PAYLOAD_ATTRIBUTES)
      else
        payload.merge! attributes.slice(*PAYLOAD_ATTRIBUTES)
      end
      payload["discard"] = ActiveModel::Type.lookup(:boolean).cast(payload["discard"])

      true
    end

    def render_in(view_context)
      view_context.render partial: "_leave_workflow/request", locals: { task: self }
    end

    def finish
      return unless can_finish?

      with_transaction_returning_status do
        if payload["discard"]
          task.instance.payload[:discard] = true
        else
          leave.update! payload.slice(*LEAVE_ATTRIBUTES)
        end
        self.finished_at = Time.zone.now
        save!
      end
    end
  end
end
