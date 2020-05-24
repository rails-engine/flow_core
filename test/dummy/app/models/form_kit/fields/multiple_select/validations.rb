# frozen_string_literal: true

class FormKit::Fields::MultipleSelect
  class Validations < FormKit::FieldOptions
    prepend FormKit::Validations::Presence
    prepend FormKit::Validations::Length
  end
end
