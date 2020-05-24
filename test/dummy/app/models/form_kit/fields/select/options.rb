# frozen_string_literal: true

class FormKit::Fields::Select
  class Options < FormKit::FieldOptions
    attribute :strict_select, :boolean, default: true
  end
end
