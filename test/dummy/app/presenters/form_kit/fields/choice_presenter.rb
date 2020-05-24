# frozen_string_literal: true

module FormKit::Fields
  class ChoicePresenter < FormKit::FieldPresenter
    def value_for_preview
      id = value
      return if id.blank?

      if choices.loaded?
        choices.target.find { |choice| choice.id == id }&.label
      else
        choices.find_by(id: id)&.label
      end
    end
  end
end
