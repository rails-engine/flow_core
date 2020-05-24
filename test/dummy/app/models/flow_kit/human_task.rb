# frozen_string_literal: true

module FlowKit
  class HumanTask < FlowCore::ApplicationRecord
    self.table_name = "flow_kit_human_tasks"

    include FlowCore::TaskExecutable

    belongs_to :workflow, class_name: "FlowCore::Workflow"
    belongs_to :instance, class_name: "FlowCore::Instance", autosave: true

    belongs_to :assignable, polymorphic: true

    enum status: {
      unassigned: "unassigned",
      assigned: "assigned",
      form_filled: "form_filled",
      finished: "finished"
    }

    delegate :payload, to: :task, prefix: :task, allow_nil: false, private: true
    delegate :payload, to: :instance, prefix: :instance, allow_nil: false, private: true

    before_validation on: :create do
      if task
        self.workflow = task.workflow
        self.instance = task.instance
      end
    end

    def form_model
      @form_model ||= workflow.form.to_virtual_model
    end

    def form_record_coder
      @_coder ||= FormCore.virtual_model_coder_class.new(form_model)
    end

    def form_record
      @form_record ||= form_model.new instance_payload
    end

    def form_record=(attributes)
      form_record.assign_attributes attributes
    end

    def can_finish?
      form_filled? && form_record.valid?
    end

    def can_assign?
      unassigned?
    end

    def can_fill_form?
      assigned? || form_filled?
    end

    def assign!(assignee)
      return unless can_assign?

      update! assignee: assignee, status: :assigned, assigned_at: Time.zone.now
    end

    def fill_form!(attributes)
      return unless can_fill_form?

      form_record.assign_attributes attributes

      task_payload.merge! form_record.serializable_hash
      self.status = :form_filled
      self.form_filled_at = Time.zone.now

      save!
    end

    def finish!
      return unless can_finish?

      instance_payload.merge! task_payload
      self.status = :finished
      self.finished_at = Time.zone.now

      save!
    end

    def render_in(_view_context)
      # noop
    end
  end
end
