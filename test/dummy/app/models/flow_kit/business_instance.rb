# frozen_string_literal: true

module FlowKit
  class BusinessInstance < FlowCore::Instance
    belongs_to :creator, polymorphic: true
    belongs_to :form, class_name: "FormKit::Form"

    validate if: ->(r) { r.form && r.form_record_changed? } do
      errors.add :form_record, :invalid if form && !form_record_valid?
    end

    before_save :serialize_form_record

    def form_model
      return unless form

      @form_model ||= form.to_virtual_model
    end

    def form_record
      return unless form

      @form_record ||= form_model.load(payload[:form_attributes])
    end

    def form_record_valid?
      return unless form

      form_record.valid?
    end

    def form_record_changed?
      return unless form

      form_record.changed?
    end

    def form_attributes=(attributes)
      return unless form

      form_record.assign_attributes attributes
    end

    private

      def serialize_form_record
        payload[:form_attributes] ||= {}
        payload[:form_attributes].merge! form_record.serializable_hash
      end
  end
end
