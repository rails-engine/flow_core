# frozen_string_literal: true

class FormKit::Fields::DecimalRange
  class Validations < FormKit::FieldOptions
    prepend FormKit::Validations::Presence
  end
end
