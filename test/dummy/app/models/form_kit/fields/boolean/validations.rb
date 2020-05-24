# frozen_string_literal: true

class FormKit::Fields::Boolean
  class Validations < FormKit::FieldOptions
    prepend FormKit::Validations::Acceptance
  end
end
