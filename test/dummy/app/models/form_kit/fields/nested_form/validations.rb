# frozen_string_literal: true

class FormKit::Fields::NestedForm
  class Validations < FormKit::FieldOptions
    prepend FormKit::Validations::Presence
  end
end
