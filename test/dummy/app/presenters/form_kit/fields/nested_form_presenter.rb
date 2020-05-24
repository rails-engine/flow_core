# frozen_string_literal: true

module FormKit::Fields
  class NestedFormPresenter < FormKit::CompositeFieldPresenter
    def nested_form_field?
      true
    end
  end
end
