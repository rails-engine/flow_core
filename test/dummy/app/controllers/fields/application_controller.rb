# frozen_string_literal: true

class Fields::ApplicationController < ApplicationController
  before_action :set_field
  before_action :set_field_layout_data

  protected

    # Use callbacks to share common setup or constraints between actions.
    def set_field
      @field = FormKit::Field.find(params[:field_id])
    end

    def set_field_layout_data
      @_breadcrumbs = [
        { text: @field.name },
        { text: "Fields", link: smart_form_fields_path(@field.form) }
      ]
      form = @field.form
      until form.class == FormKit::Form
        field = form.attachable
        url = smart_form_fields_path(form)

        @_breadcrumbs << { text: field.name, link: url }

        form = field.form
      end
      unless form == @field.form
        @_breadcrumbs << { text: "Fields", link: form_fields_path(form) }
      end
      @_breadcrumbs << { text: form.name, link: form_path(form) }
      @_breadcrumbs << { text: "Forms", link: forms_path }
      @_breadcrumbs.reverse!
    end

    def fields_url
      form = @field.form

      case form
      when FormKit::Form
        form_fields_url(form)
      when FormKit::NestedForm
        nested_form_fields_url(form)
      else
        raise "Unknown form: #{form.class}"
      end
    end

    def smart_form_fields_path(form)
      case form
      when FormKit::Form
        form_fields_path(form)
      when FormKit::NestedForm
        nested_form_fields_path(form)
      else
        raise "Unknown form: #{form.class}"
      end
    end
end
