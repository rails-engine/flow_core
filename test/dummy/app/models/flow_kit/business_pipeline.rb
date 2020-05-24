# frozen_string_literal: true

module FlowKit
  class BusinessPipeline < FlowCore::Pipeline
    belongs_to :form, class_name: "FormKit::Form"

    private

      def on_build_workflow(workflow)
        workflow.form = form
      end

      def workflow_class
        FlowKit::BusinessWorkflow
      end
  end
end
