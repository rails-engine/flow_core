# frozen_string_literal: true

class FormKit::Fields::MultipleNestedForm
  class Validations < FormKit::FieldOptions
    prepend FormKit::Validations::Presence
    prepend FormKit::Validations::Length
  end
end
