# frozen_string_literal: true

module FlowCore
  class Arc < FlowCore::ApplicationRecord
    self.table_name = "flow_core_arcs"

    belongs_to :workflow, class_name: "FlowCore::Workflow"
    belongs_to :transition, class_name: "FlowCore::Transition"
    belongs_to :place, class_name: "FlowCore::Place"

    has_many :guards, class_name: "FlowCore::ArcGuard", dependent: :delete_all

    enum direction: {
      in: 0,
      out: 1
    }

    validates :place,
              uniqueness: {
                scope: %i[workflow transition direction]
              }
    validates :fallback_arc,
              uniqueness: {
                scope: %i[workflow transition direction]
              }, if: :fallback_arc?

    before_validation on: :create do
      self.workflow ||= place&.workflow || transition&.workflow
    end

    before_destroy :prevent_destroy
    after_create :reset_workflow_verification
    after_destroy :reset_workflow_verification

    def can_destroy?
      workflow.instances.empty?
    end

    private

      def reset_workflow_verification
        workflow.reset_workflow_verification!
      end

      def prevent_destroy
        unless can_destroy?
          raise FlowCore::ForbiddenOperation, "Found exists instance, destroy transition will lead serious corruption"
        end
      end
  end
end
