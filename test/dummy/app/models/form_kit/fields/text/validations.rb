# frozen_string_literal: true

class FormKit::Fields::Text
  class Validations < FormKit::FieldOptions
    prepend FormKit::Validations::Presence
    prepend FormKit::Validations::Length
    prepend FormKit::Validations::Format
    # prepend FormKit::Validations::Uniqueness
  end
end
