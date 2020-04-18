# frozen_string_literal: true

class HumanTask < ApplicationRecord
  include FlowCore::TaskExecutable

  belongs_to :assignee, class_name: "User", optional: true

  delegate :payload, to: :task, allow_nil: false

  def finished?
    finished_at.present?
  end

  def can_finish?
    valid?
  end

  def finish
    return unless can_finish?

    with_transaction_returning_status do
      self.finished_at = Time.zone.now
      save!
    end
  end

  def render_in(_view_context)
    # noop
  end

  def set_payload(params: nil, attributes: nil)
    unless params || attributes
      raise ArgumentError, "Must provide `params` or `attributes`"
    end

    if params
      assign_attributes params.permit!
    else
      assign_attributes attributes
    end
  end

  def update_payload(params: nil, attributes: nil)
    set_payload params: params, attributes: attributes
    save
  end
end
