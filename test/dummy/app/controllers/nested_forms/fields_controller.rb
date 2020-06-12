# frozen_string_literal: true

class NestedForms::FieldsController < NestedForms::ApplicationController
  before_action :set_field, only: %i[show edit update destroy]
  before_action :set_field_page_layout, only: %i[index new create show edit update]

  def index
    @fields = @nested_form.fields.order(position: :asc)
  end

  def new
    @field = @nested_form.fields.build
  end

  def edit; end

  def create
    @field = @nested_form.fields.build(field_params)

    if @field.save
      redirect_to nested_form_fields_url(@nested_form), notice: "Field was successfully created."
    else
      render :new
    end
  end

  def update
    if @field.update(field_params)
      redirect_to nested_form_fields_url(@nested_form), notice: "Field was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @field.destroy
    redirect_to nested_form_fields_url(@nested_form), notice: "Field was successfully destroyed."
  end

  def move
    @field = @nested_form.fields.find(params[:field_id])
    if @field && params[:position].present?
      index = params[:position].to_i
      @field.insert_at(index)
    end

    head :no_content
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_field
      @field = @nested_form.fields.find(params[:id])
    end

    def set_field_page_layout
      @_breadcrumbs << { text: "Fields", link: nested_form_fields_path(@nested_form) }
      if @field
        @_breadcrumbs << { text: @field.name }
      end
    end

    # Only allow a trusted parameter "white list" through.
    def field_params
      params.fetch(:field, {}).permit(:key, :name, :hint, :accessibility, :type)
    end
end
