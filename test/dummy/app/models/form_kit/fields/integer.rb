# frozen_string_literal: true

module FormKit::Fields
  class Integer < FormKit::Field
    serialize :validations, coder: Validations
    serialize :options, coder: Options

    def stored_type
      :integer
    end

    protected

      def interpret_extra_to(model, accessibility, _overrides = {})
        return if accessibility != :read_and_write

        model.validates key, numericality: { only_integer: true }, allow_blank: true
      end
  end
end
