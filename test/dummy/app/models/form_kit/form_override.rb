# frozen_string_literal: true

module FormKit
  class FormOverride < ApplicationRecord
    self.table_name = "form_kit_form_overrides"

    belongs_to :form, class_name: "FormKit::MetalForm", foreign_key: "form_id"

    has_many :field_overrides, class_name: "FormKit::FieldOverride", inverse_of: :form_override, dependent: :delete_all, validate: true, autosave: true

    accepts_nested_attributes_for :field_overrides, reject_if: proc { |attributes| attributes["accessibility"].blank? }

    def to_overrides_options
      hash = {}

      field_overrides.includes(:field).each do |field_override|
        hash[field_override.field.key] = {
          accessibility: field_override.accessibility.to_sym
        }
      end

      hash
    end
  end
end
