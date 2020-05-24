# frozen_string_literal: true

module FormKit::Fields
  class MultipleChoicePresenter < FormKit::FieldPresenter
    def value_for_preview
      ids = Array.wrap(value)
      return if ids.blank?

      if choices.loaded?
        choices.target.select { |choice| ids.include?(choice.id) }.map(&:label)
      else
        choices.where(id: ids).map(&:label)
      end.join(", ")
    end
  end
end
