# frozen_string_literal: true

class ApprovalTask < UserTask
  include FlowCore::TaskExecutable

  def can_finish?
    !approved.nil? && valid?
  end

  def finish!
    return unless can_finish?

    transaction do
      set_payload! approved: approved, comment: comment
      update! finished: true
    end
  end
end
