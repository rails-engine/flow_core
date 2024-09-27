# frozen_string_literal: true

class Forms::PreviewsController < Forms::ApplicationController
  before_action :set_strict_loaded_fields
  before_action :set_preview
  before_action :set_preview_page_layout

  def show
    @instance = @preview.new
  end

  def create
    @instance = @preview.new(preview_params)
    if @instance.valid?
      render :create
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

    def set_preview
      @preview = @form.to_virtual_model
    end

    def set_preview_page_layout
      @_breadcrumbs << { text: "Preview" }
    end

    def preview_params
      params.fetch(:preview, {}).permit!
    end
end
