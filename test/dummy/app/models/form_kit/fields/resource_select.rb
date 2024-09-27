# frozen_string_literal: true

module FormKit::Fields
  class ResourceSelect < FormKit::Field
    serialize :options, coder: Options
    serialize :validations, coder: Validations

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

    protected

      def interpret_extra_to(model, accessibility, _overrides = {})
        return if accessibility != :read_and_write || !options.strict_select

        model.validates key, inclusion: { in: -> { collection } }, allow_blank: true
      end
  end
end
