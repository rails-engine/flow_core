# frozen_string_literal: true

module FormKit::Fields
  def self.all_types
    @all_types ||= [
      FormKit::Fields::Text,
      FormKit::Fields::Boolean,
      FormKit::Fields::Decimal,
      FormKit::Fields::Integer,
      FormKit::Fields::Date,
      FormKit::Fields::Datetime,
      FormKit::Fields::Choice,
      FormKit::Fields::MultipleChoice,
      FormKit::Fields::Select,
      FormKit::Fields::MultipleSelect,
      FormKit::Fields::IntegerRange,
      FormKit::Fields::DecimalRange,
      FormKit::Fields::DateRange,
      FormKit::Fields::DatetimeRange,
      FormKit::Fields::NestedForm,
      FormKit::Fields::MultipleNestedForm,
      # FormKit::Fields::ResourceSelect,
      # FormKit::Fields::MultipleResourceSelect,
      # FormKit::Fields::Resource,
      # FormKit::Fields::MultipleResource,
    ]
  end
end
