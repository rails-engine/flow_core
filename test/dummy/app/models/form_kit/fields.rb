# frozen_string_literal: true

module FormKit::Fields
  %w[
    text boolean decimal integer
    date datetime
    choice multiple_choice
    select multiple_select
    integer_range decimal_range date_range datetime_range
    nested_form multiple_nested_form

    resource_select multiple_resource_select
    resource multiple_resource
  ].each do |type|
    require_dependency "form_kit/fields/#{type}"
  end

  MAP = Hash[*FormKit::Field.descendants.map { |f| [f.type_key, f] }.flatten]
end
