# frozen_string_literal: true

class FormKit::Fields::MultipleResourceSelect
  class Validations < FormKit::FieldOptions
    prepend FormKit::Validations::Presence
    prepend FormKit::Validations::Length
  end
end
