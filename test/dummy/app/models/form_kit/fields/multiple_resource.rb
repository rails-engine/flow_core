# frozen_string_literal: true

module FormKit::Fields
  class MultipleResource < FormKit::Field
    serialize :validations, coder: Validations
    serialize :options, coder: Options

    def stored_type
      :string
    end

    delegate :data_source, to: :options

    def collection
      data_source.scoped_records
    end

    def attached_data_source?
      true
    end

    def array?
      true
    end

    protected

      def interpret_extra_to(model, accessibility, _overrides = {})
        return if accessibility != :read_and_write

        model.validates key, subset: { in: -> { collection } }, allow_blank: true
      end
  end
end
