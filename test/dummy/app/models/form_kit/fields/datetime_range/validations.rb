# frozen_string_literal: true

class FormKit::Fields::DatetimeRange
  class Validations < FormKit::FieldOptions
    prepend FormKit::Validations::Presence
  end
end
