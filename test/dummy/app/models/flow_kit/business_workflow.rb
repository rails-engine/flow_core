# frozen_string_literal: true

module FlowKit
  class BusinessWorkflow < FlowCore::Workflow
    belongs_to :form, class_name: "FormKit::Form"

    def on_instance_create_validation(instance)
      instance.errors.add :creator, :presence unless instance.creator

      payload_record = payload_model.new instance.payload
      instance.errors.add :payload, :invalid unless payload_record.valid?
    end

    def on_instance_task_enable(task)
      task.payload.merge! task.instance.payload
      task.save!
    end

    def payload_model
      @form_model ||= form.to_virtual_model
    end
  end
end
