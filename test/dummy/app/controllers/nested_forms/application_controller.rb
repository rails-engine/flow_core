# frozen_string_literal: true

class NestedForms::ApplicationController < ApplicationController
  before_action :set_nested_form
  before_action :set_nested_form_layout_data

  protected

    # Use callbacks to share common setup or constraints between actions.
    def set_nested_form
      @nested_form = FormKit::NestedForm.find(params[:nested_form_id])
    end

    def set_nested_form_layout_data
      @_breadcrumbs = []
      form = @nested_form
      until form.class == FormKit::Form
        field = form.attachable
        url =
          case form
          when FormKit::Form
            form_path(form)
          when FormKit::NestedForm
            nested_form_fields_path(form)
          else
            raise "Unknown form: #{form.class}"
          end

        @_breadcrumbs << { text: field.name, link: url }

        form = field.form
      end
      @_breadcrumbs << { text: "Fields", link: form_fields_path(form) }
      @_breadcrumbs << { text: form.name, link: form_path(form) }
      @_breadcrumbs << { text: "Forms", link: forms_path }
      @_breadcrumbs.reverse!
    end
end
