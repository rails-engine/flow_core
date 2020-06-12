# frozen_string_literal: true

module FormKit
  class MetalForm < ApplicationRecord
    self.table_name = "form_kit_forms"

    has_many :fields, class_name: "FormKit::Field", foreign_key: "form_id", inverse_of: :form, dependent: :destroy

    has_many :overrides, class_name: "FormKit::FormOverride", foreign_key: "form_id", dependent: :destroy

    validates :key,
              presence: true,
              uniqueness: true

    default_value_for :key,
                      ->(_) { "form_#{SecureRandom.hex(3)}" },
                      allow_nil: false

    def to_virtual_model(model_name: "VirtualForm",
                         fields_scope: proc { |fields| fields },
                         overrides: {})
      model = FormKit::VirtualModel.build model_name

      append_to_virtual_model(model, fields_scope: fields_scope, overrides: overrides)
    end

    def append_to_virtual_model(model,
                                fields_scope: proc { |fields| fields },
                                overrides: {})
      unless model.is_a?(Class) && model < FormKit::VirtualModel
        raise ArgumentError, "#{model} must be a #{::FormKit::VirtualModel}'s subclass"
      end

      global_overrides = overrides.fetch(:_global, {})
      fields_scope.call(fields).each do |f|
        f.interpret_to model, overrides: global_overrides.merge(overrides.fetch(f.key, {}))
      end

      model
    end
  end
end
