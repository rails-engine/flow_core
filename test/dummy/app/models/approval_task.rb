# frozen_string_literal: true

class ApprovalTask < HumanTask
  def approved
    payload["approved"]
  end

  def comment
    payload["comment"]
  end

  PAYLOAD_ATTRIBUTES = %w[approved comment].freeze
  def set_payload(params: nil, attributes: nil)
    unless params || attributes
      raise ArgumentError, "Must provide `params` or `attributes`"
    end

    if params
      payload.merge! params.permit(*PAYLOAD_ATTRIBUTES)
    else
      payload.merge! attributes.slice(*PAYLOAD_ATTRIBUTES)
    end
    payload[:approved] = ActiveModel::Type.lookup(:boolean).cast(payload["approved"])

    true
  end

  def can_finish?
    !approved.nil? && valid?
  end

  def finish
    return unless can_finish?

    with_transaction_returning_status do
      self.finished_at = Time.zone.now
      save!
    end
  end
end
