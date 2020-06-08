# frozen_string_literal: true

module FlowKit
  class BusinessWorkflow < FlowCore::Workflow
    belongs_to :form, class_name: "FormKit::Form"

    def on_instance_create_validation(instance)
      instance.errors.add :creator, :presence unless instance.creator

      form_record = form_model.new instance.payload.fetch(:form_attributes, {})
      instance.errors.add :payload, :invalid unless form_record.valid?
    end

    def on_instance_task_finish(task)
      unless task.executable
        task.payload[:form_attributes] = task.instance.payload.fetch(:form_attributes, {})
        task.save!
      end
    end

    def form_model
      @form_model ||= form.to_virtual_model
    end
  end
end
