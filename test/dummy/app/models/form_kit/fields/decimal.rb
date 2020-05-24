# frozen_string_literal: true

module FormKit::Fields
  class Decimal < FormKit::Field
    serialize :validations, Validations
    serialize :options, Options

    def stored_type
      :decimal
    end
  end
end
