# frozen_string_literal: true

module FormKit
  class CompositeFieldPresenter < FormKit::FieldPresenter
    def value
      target&.send(@model.key)
    end

    def value_for_preview
      target&.send(@model.key)
    end
  end
end
