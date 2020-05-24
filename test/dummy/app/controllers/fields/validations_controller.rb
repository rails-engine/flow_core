# frozen_string_literal: true

class Fields::ValidationsController < Fields::ApplicationController
  before_action :set_validations
  before_action :set_page_layout

  def edit; end

  def update
    @validations.assign_attributes(validations_params)
    if @validations.valid? && @field.save(validate: false)
      redirect_to fields_url, notice: "Field was successfully updated."
    else
      render :edit
    end
  end

  private

    def set_validations
      @validations = @field.validations
    end

    def set_page_layout
      @_breadcrumbs << { text: "Validation" }
    end

    def validations_params
      params.fetch(:validations, {}).permit!
    end
end
