# frozen_string_literal: true

module FormKit::Fields
  class SelectPresenter < FormKit::FieldPresenter
    def include_blank?
      required?
    end

    def can_custom_value?
      !@model.options.strict_select
    end

    def collection
      collection = @model.choices.map(&:label)
      if can_custom_value? && value.present?
        ([value] + collection).uniq
      else
        collection
      end
    end

    def options_for_select
      @view.options_for_select(collection, value)
    end
  end
end
