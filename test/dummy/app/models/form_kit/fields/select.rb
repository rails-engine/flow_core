# frozen_string_literal: true

module FormKit::Fields
  class Select < FormKit::Field
    serialize :validations, coder: Validations
    serialize :options, coder: Options

    include Fakable

    def stored_type
      :string
    end

    def attached_choices?
      true
    end

    protected

      def interpret_extra_to(model, accessibility, _overrides = {})
        return if accessibility != :read_and_write || !options.strict_select

        model.validates key, inclusion: { in: choices.pluck(:label) }, allow_blank: true
      end
  end
end
