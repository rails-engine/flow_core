# frozen_string_literal: true

class FormKit::Fields::ResourceSelect
  class Options < FormKit::FieldOptions
    include FormKit::Options::DataSource

    attribute :strict_select, :boolean, default: true
  end
end
