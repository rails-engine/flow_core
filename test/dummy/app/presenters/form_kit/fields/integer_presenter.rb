# frozen_string_literal: true

module FormKit::Fields
  class IntegerPresenter < FormKit::FieldPresenter
    include FormKit::Fields::PresenterForNumberField

    def integer_only?
      true
    end
  end
end
