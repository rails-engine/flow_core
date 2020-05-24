# frozen_string_literal: true

module FlowCore
  class Pipeline < FlowCore::ApplicationRecord
    self.table_name = "flow_core_pipelines"

    has_many :generated_workflows,
             class_name: "FlowCore::Workflow", foreign_key: :generated_by_pipeline_id,
             inverse_of: :generated_by, dependent: :nullify

    has_many :steps, -> { where(branch_id: nil).order(position: :asc) },
             class_name: "FlowCore::Step", inverse_of: :pipeline,
             dependent: :destroy

    has_many :branches, class_name: "FlowCore::Branch", dependent: :restrict_with_exception
    has_many :whole_steps, class_name: "FlowCore::Step", inverse_of: :pipeline, dependent: :restrict_with_exception

    validates :name,
              presence: true

    def deploy_workflow
      return if steps.empty?
      return if whole_steps.exists? verified: false

      workflow = nil
      transaction do
        workflow = generated_workflows.new name: name, type: workflow_class.to_s
        on_build_workflow(workflow)
        workflow.save!

        end_place = workflow.create_end_place!

        place_or_transition = nil
        steps.each do |step|
          place_or_transition = step.deploy_to_workflow!(workflow, place_or_transition)
        end

        if place_or_transition.is_a? FlowCore::Place
          place_or_transition.input_arcs.update place: end_place
          place_or_transition.reload.destroy!
        else
          end_place.input_transitions << place_or_transition
        end
      end
      workflow&.verify!

      workflow
    end

    private

      def on_build_workflow(_workflow); end

      def workflow_class
        FlowCore::Workflow
      end
  end
end
