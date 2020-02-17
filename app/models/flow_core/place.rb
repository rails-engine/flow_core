# frozen_string_literal: true

module FlowCore
  class Place < FlowCore::ApplicationRecord
    self.table_name = "flow_core_places"

    FORBIDDEN_ATTRIBUTES = %i[workflow_id created_at updated_at].freeze

    belongs_to :workflow, class_name: "FlowCore::Workflow"

    # NOTE: Place - out -> Transition - in -> Place
    has_many :input_arcs, -> { where direction: :out },
             class_name: "FlowCore::Arc", inverse_of: :place, dependent: :delete_all
    has_many :output_arcs, -> { where direction: :in },
             class_name: "FlowCore::Arc", inverse_of: :place, dependent: :delete_all

    has_many :output_transitions, through: :output_arcs, class_name: "FlowCore::Transition", source: :transition

    before_destroy :prevent_destroy
    after_create :reset_workflow_verification
    after_destroy :reset_workflow_verification

    def output_implicit_or_split?
      output_arcs.size > 1
    end

    def input_or_join?
      input_arcs.size > 1
    end

    def input_sequence?
      input_arcs.size == 1
    end

    def output_sequence?
      output_arcs.size == 1
    end

    def start?
      false
    end

    def end?
      false
    end

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
