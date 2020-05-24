# frozen_string_literal: true

module FormKit::Fields
  class MultipleNestedFormPresenter < FormKit::CompositeFieldPresenter
    def multiple_nested_form?
      true
    end
  end
end
