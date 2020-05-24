# frozen_string_literal: true

module FormKit::Fields
  class NestedForm < FormKit::Field
    after_create do
      build_nested_form.save!
    end

    serialize :validations, Validations
    serialize :options, FormKit::NonConfigurable

    def attached_nested_form?
      true
    end

    protected

      def interpret_attribute_to(model, accessibility, _overrides = {})
        nested_model = nested_form.to_virtual_model(overrides: { _global: { accessibility: accessibility } })
        model.nested_models[key] = nested_model

        name = key.to_sym
        model.embeds_one name, anonymous_class: nested_model, validate: true
        model.accepts_nested_attributes_for name, reject_if: :all_blank
      end
  end
end
