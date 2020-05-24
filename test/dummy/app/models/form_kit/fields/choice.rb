# frozen_string_literal: true

module FormKit::Fields
  class Choice < FormKit::Field
    serialize :validations, Validations
    serialize :options, FormKit::NonConfigurable

    include Fakable

    def stored_type
      :integer
    end

    def attached_choices?
      true
    end

    protected

      def interpret_extra_to(model, accessibility, _overrides = {})
        return if accessibility != :read_and_write

        choice_ids = choices.pluck(:id)
        return if choice_ids.empty?

        model.validates key, inclusion: { in: choice_ids }, allow_blank: true
      end
  end
end
