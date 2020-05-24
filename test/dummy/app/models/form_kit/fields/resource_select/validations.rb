# frozen_string_literal: true

class FormKit::Fields::ResourceSelect
  class Validations < FormKit::FieldOptions
    prepend FormKit::Validations::Presence
    # prepend FormKit::Validations::Uniqueness
  end
end
