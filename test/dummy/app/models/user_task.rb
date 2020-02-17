# frozen_string_literal: true

class UserTask < ApplicationRecord
  include FlowCore::TaskExecutable

  belongs_to :assignee, class_name: "User", optional: true

  def finished?
    finished
  end

  def can_finish?
    valid?
  end

  def finish!
    return unless can_finish?

    transaction do
      update! finished: true
    end
  end

  def set_payload!(payload)
    task.payload.merge! payload
    task.save!
  end
end
