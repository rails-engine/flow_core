# frozen_string_literal: true

class FormKit::Fields::Select
  class Validations < FormKit::FieldOptions
    prepend FormKit::Validations::Presence
    # prepend FormKit::Validations::Uniqueness
  end
end
