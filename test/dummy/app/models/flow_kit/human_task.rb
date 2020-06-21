# frozen_string_literal: true

module FlowKit
  class HumanTask < FlowCore::ApplicationRecord
    self.table_name = "flow_kit_human_tasks"

    include FlowCore::TaskExecutable

    belongs_to :workflow, class_name: "FlowCore::Workflow"
    belongs_to :instance, class_name: "FlowCore::Instance", autosave: true

    belongs_to :form_override, class_name: "FormKit::FormOverride", optional: true
    belongs_to :attached_form, class_name: "FormKit::Form", optional: true
    belongs_to :assignable, polymorphic: true, optional: true

    enum status: {
      unassigned: "unassigned",
      assigned: "assigned",
      form_filled: "form_filled",
      finished: "finished"
    }

    delegate :form, to: :instance, allow_nil: false
    delegate :payload, to: :task, prefix: :task, allow_nil: false, private: true
    delegate :payload, to: :instance, prefix: :instance, allow_nil: false, private: true

    before_validation on: :create do
      if task
        self.workflow = task.workflow
        self.instance = task.instance
      end
    end

    validate if: :persisted? do
      errors.add :form_record, :invalid if form && !form_record_valid?
      errors.add :attached_form_record, :invalid if attached_form && !attached_form_record_valid?
    end

    def form_attributes
      @instance_form_attributes ||=
        begin
          task_payload[:form_attributes] ||= {}
          task_payload[:form_attributes]
        end
    end

    def attached_form_attributes
      @attached_form_attributes ||=
        begin
          task_payload[:attached_form_attributes] ||= {}
          task_payload[:attached_form_attributes]
        end
    end

    def form_attached?
      form.present?
    end

    def attached_form_attached?
      attached_form.present?
    end

    def form_model
      return unless form_attached?

      @form_model ||= form.to_virtual_model(overrides: form_override&.to_overrides_options || {})
    end

    def attached_form_model
      return unless attached_form_attached?

      @task_form_model ||= attached_form.to_virtual_model
    end

    def form_record
      return unless form_attached?

      @form_record ||=
        if form_filled? || finished?
          form_model.load form_attributes
        else
          form_model.load(instance_payload[:form_attributes] || {})
        end
    end

    def attached_form_record
      return unless attached_form_attached?

      @attached_form_record ||= attached_form_model.new attached_form_attributes
    end

    def form_record_valid?
      return true unless form_attached?

      form_record.valid?
    end

    def attached_form_record_valid?
      return true unless attached_form_attached?

      attached_form_record.valid?
    end

    def form_attributes=(attributes)
      return unless form_attached?

      form_record.assign_attributes attributes
    end

    def attached_form_attributes=(attributes)
      return unless attached_form_attached?

      attached_form_record.assign_attributes attributes
    end

    def can_finish?
      form_filled? && form_record_valid? && attached_form_record_valid?
    end

    def can_assign?
      unassigned?
    end

    def can_fill_form?
      assigned? || form_filled?
    end

    def assign!(assignee)
      return unless can_assign?
      return unless assignee

      transaction do
        update! assignable: assignee, status: :assigned, assigned_at: Time.zone.now
        assignee.notifications.create! task: task
      end
    end

    def fill_form!(attributes)
      return unless can_fill_form?

      if form_attached?
        form_record_attributes = attributes.fetch :form_attributes, {}
        form_record.assign_attributes form_record_attributes

        form_attributes.merge! form_record.serializable_hash
      end

      if attached_form_attached?
        attached_form_record_attributes = attributes.fetch :attached_form_attributes, {}
        attached_form_record.assign_attributes attached_form_record_attributes

        attached_form_attributes.merge! attached_form_record.serializable_hash
      end

      self.status = :form_filled
      self.form_filled_at = Time.zone.now

      save
    end

    def finish!
      return unless can_finish?

      if form_attached?
        instance_payload[:form_attributes] ||= {}
        instance_payload[:form_attributes].merge! form_attributes
      end

      self.status = :finished
      self.finished_at = Time.zone.now

      save!
    end
  end
end
