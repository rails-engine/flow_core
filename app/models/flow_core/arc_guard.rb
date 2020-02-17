# frozen_string_literal: true

module FlowCore
  class ArcGuard < FlowCore::ApplicationRecord
    self.table_name = "flow_core_arc_guards"

    belongs_to :workflow, class_name: "FlowCore::Workflow"
    belongs_to :arc, class_name: "FlowCore::Arc"

    has_one :transition, through: :arc, class_name: "FlowCore::Transition"

    before_validation do
      self.workflow ||= arc&.workflow
    end

    include FlowCore::ArcGuardable
  end
end
