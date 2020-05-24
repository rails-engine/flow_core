# frozen_string_literal: true

module FlowKit
  class AssigneeCandidate < FlowCore::ApplicationRecord
    self.table_name = "flow_kit_assignee_candidates"

    belongs_to :assignable, polymorphic: true
    belongs_to :trigger, class_name: "FlowCore::TransitionTrigger"
  end
end
