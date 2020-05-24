# frozen_string_literal: true

class FormKit::Fields::Integer
  class Options < FormKit::FieldOptions
    attribute :step, :integer, default: 0

    validates :step,
              numericality: {
                only_integer: true,
                greater_than_or_equal_to: 0
              }
  end
end
