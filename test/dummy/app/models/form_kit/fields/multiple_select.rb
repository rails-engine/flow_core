# frozen_string_literal: true

module FormKit::Fields
  class MultipleSelect < FormKit::Field
    serialize :validations, Validations
    serialize :options, Options

    include Fakable

    def stored_type
      :string
    end

    def attached_choices?
      true
    end

    def array?
      true
    end

    protected

      def interpret_extra_to(model, accessibility, _overrides = {})
        return if accessibility != :read_and_write || !options.strict_select

        model.validates key, subset: { in: choices.pluck(:label) }, allow_blank: true
      end
  end
end
