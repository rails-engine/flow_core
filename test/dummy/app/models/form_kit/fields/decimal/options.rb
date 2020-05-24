# frozen_string_literal: true

class FormKit::Fields::Decimal
  class Options < FormKit::FieldOptions
    attribute :step, :decimal, default: 0.01

    validates :step,
              numericality: {
                greater_than_or_equal_to: 0.0
              }
  end
end
