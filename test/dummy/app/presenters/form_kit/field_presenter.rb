# frozen_string_literal: true

module FormKit
  class FieldPresenter < ApplicationPresenter
    def required
      @model.validations&.presence
    end
    alias required? required

    def target
      @options[:target]
    end

    def value
      if target.respond_to?(:read_attribute)
        target.read_attribute(@model.key)
      else
        target
      end
    end

    def value_for_preview
      value
    end

    def disabled?
      access_readonly?
    end

    def access_readonly?
      target.class.attr_readonly?(@model.key)
    end

    def access_hidden?
      target.class.attribute_names.exclude?(@model.key.to_s) && target.class._reflections.keys.exclude?(@model.key.to_s)
    end

    def access_read_and_write?
      !access_readonly? &&
        (target.class.attribute_names.include?(@model.key.to_s) || target.class._reflections.key?(@model.key.to_s))
    end

    def id
      "form_field_#{@model.id}"
    end

    def nested_form_field?
      false
    end

    def multiple_nested_form?
      false
    end
  end
end
