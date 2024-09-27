# frozen_string_literal: true

module FormKit::Fields
  class Decimal < FormKit::Field
    serialize :validations, coder: Validations
    serialize :options, coder: Options

    def stored_type
      :decimal
    end
  end
end
