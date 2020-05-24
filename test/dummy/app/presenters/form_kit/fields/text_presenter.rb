# frozen_string_literal: true

module FormKit::Fields
  class TextPresenter < FormKit::FieldPresenter
    def multiline
      @model.options.multiline
    end
    alias multiline? multiline
  end
end
