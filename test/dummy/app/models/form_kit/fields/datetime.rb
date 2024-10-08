# frozen_string_literal: true

module FormKit::Fields
  class Datetime < FormKit::Field
    serialize :validations, coder: Validations
    serialize :options, coder: Options

    def stored_type
      :datetime
    end

    protected

      def interpret_extra_to(model, _accessibility, _overrides = {})
        model.class_eval <<-CODE, __FILE__, __LINE__ + 1
          def #{key}=(val)
            super(val.try(:in_time_zone)&.utc)
          end
        CODE
      end
  end
end
