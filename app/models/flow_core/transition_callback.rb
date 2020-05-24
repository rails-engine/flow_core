# frozen_string_literal: true

module FlowCore
  class TransitionCallback < FlowCore::ApplicationRecord
    self.table_name = "flow_core_transition_callbacks"

    belongs_to :workflow, class_name: "FlowCore::Workflow", optional: true
    belongs_to :transition, class_name: "FlowCore::Transition", optional: true

    belongs_to :pipeline, class_name: "FlowCore::Pipeline", optional: true
    belongs_to :step, class_name: "FlowCore::Step", optional: true

    validates :transition,
              presence: true,
              if: ->(r) { r.workflow }
    validates :step,
              presence: true,
              if: ->(r) { r.pipeline }
    validates :workflow,
              presence: true,
              if: ->(r) { !r.pipeline }
    validates :pipeline,
              presence: true,
              if: ->(r) { !r.workflow }

    before_validation do
      self.workflow ||= transition&.workflow
      self.pipeline ||= step&.pipeline
    end

    def configurable?
      false
    end

    def type_key
      self.class.to_s.split("::").last.underscore
    end

    include FlowCore::TransitionCallbackable
  end
end
