# frozen_string_literal: true

class FormKit::Fields::IntegerRange
  class Validations < FormKit::FieldOptions
    prepend FormKit::Validations::Presence
  end
end
