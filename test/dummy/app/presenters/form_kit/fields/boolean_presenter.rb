# frozen_string_literal: true

module FormKit::Fields
  class BooleanPresenter < FormKit::FieldPresenter
    def required
      @model.validations&.acceptance
    end

    def value_for_preview
      super ? I18n.t("values.true") : I18n.t("values.false")
    end
  end
end
