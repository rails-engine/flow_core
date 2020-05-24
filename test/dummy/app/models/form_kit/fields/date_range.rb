# frozen_string_literal: true

module FormKit::Fields
  class DateRange < FormKit::Field
    serialize :validations, Validations
    serialize :options, Options

    protected

      def interpret_attribute_to(model, _accessibility, _overrides = {})
        nested_model = Class.new(FormKit::Embeds::DateRange)
        model.nested_models[key] = nested_model

        name = key.to_sym
        model.embeds_one name, anonymous_class: nested_model, validate: true
        model.accepts_nested_attributes_for name, reject_if: :all_blank
      end
  end
end
