# frozen_string_literal: true

module FormKit::Fields
  class MemberPresenter < FormKit::FieldPresenter
    def value_for_preview
      id = value
      return if id.blank?

      collection.find_by(id: id)&.name
    end

    def include_blank?
      required?
    end

    def collection
      @model.collection
    end

    def options_for_select
      @view.options_from_collection_for_select(
        collection, :id, :name, value
      )
    end
  end
end
