# frozen_string_literal: true

module FlowCore
  class ArcGuard < FlowCore::ApplicationRecord
    self.table_name = "flow_core_arc_guards"

    belongs_to :workflow, class_name: "FlowCore::Workflow", optional: true
    belongs_to :arc, class_name: "FlowCore::Arc", optional: true

    has_one :transition, through: :arc, class_name: "FlowCore::Transition"

    belongs_to :pipeline, class_name: "FlowCore::Pipeline", optional: true
    belongs_to :branch, class_name: "FlowCore::Branch", optional: true

    validates :arc,
              presence: true,
              if: ->(r) { r.workflow }
    validates :branch,
              presence: true,
              if: ->(r) { r.pipeline }
    validates :workflow,
              presence: true,
              if: ->(r) { !r.pipeline }
    validates :pipeline,
              presence: true,
              if: ->(r) { !r.workflow }

    before_validation do
      self.workflow ||= arc&.workflow
      self.pipeline ||= branch&.pipeline
    end

    def configurable?
      false
    end

    def type_key
      self.class.to_s.split("::").last.underscore
    end

    include FlowCore::ArcGuardable
  end
end
