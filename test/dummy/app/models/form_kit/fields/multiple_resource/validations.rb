# frozen_string_literal: true

class FormKit::Fields::MultipleResource
  class Validations < FormKit::FieldOptions
    prepend FormKit::Validations::Presence
    prepend FormKit::Validations::Length
  end
end
