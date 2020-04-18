# frozen_string_literal: true

class Leave < ApplicationRecord
  belongs_to :user

  belongs_to :workflow_instance, class_name: "FlowCore::Instance", optional: true
  has_many :approval_tasks, as: :attachable, class_name: "ApprovalTask"

  enum stage: {
    created: "created",
    evaluating: "evaluating",
    obsoleted: "obsoleted",
    ongoing: "ongoing",
    finished: "finished"
  }

  validates :reason, :start_date, :end_date,
            presence: true

  validates :end_date,
            timeliness: {
              after: :start_date,
              type: :date
            }
end
