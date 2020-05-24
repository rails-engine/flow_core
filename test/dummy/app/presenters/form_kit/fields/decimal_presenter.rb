# frozen_string_literal: true

module FormKit::Fields
  class DecimalPresenter < FormKit::FieldPresenter
    include FormKit::Fields::PresenterForNumberField
  end
end
