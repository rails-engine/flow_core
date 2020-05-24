# frozen_string_literal: true

class Forms::ApplicationController < ApplicationController
  before_action :set_form
  before_action :set_form_layout_data

  protected

    # Use callbacks to share common setup or constraints between actions.
    def set_form
      @form = FormKit::Form.find(params[:form_id])
    end

    def set_strict_loaded_fields
      @form.fields.includes(:choices)
    end

    def set_form_layout_data
      @_breadcrumbs =
        [
          { text: "Forms", link: forms_path },
          { text: @form.name, link: form_path(@form) }
        ]
    end
end
