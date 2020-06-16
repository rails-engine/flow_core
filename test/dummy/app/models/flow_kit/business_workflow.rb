# frozen_string_literal: true

module FlowKit
  class BusinessWorkflow < FlowCore::Workflow
    belongs_to :form, class_name: "FormKit::Form"

    private

      def on_build_instance(instance)
        instance.form = form
      end

      def instance_class
        FlowKit::BusinessInstance
      end
  end
end
