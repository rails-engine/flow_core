# frozen_string_literal: true

class FormKit::Fields::Text
  class Options < FormKit::FieldOptions
    attribute :multiline, :boolean, default: false
  end
end
