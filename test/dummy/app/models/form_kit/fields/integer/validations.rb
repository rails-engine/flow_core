# frozen_string_literal: true

class FormKit::Fields::Integer
  class Validations < FormKit::FieldOptions
    prepend FormKit::Validations::Presence
    prepend FormKit::Validations::Numericality
    # prepend FormKit::Validations::Uniqueness
  end
end
