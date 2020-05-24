# frozen_string_literal: true

class Forms::FieldsController < Forms::ApplicationController
  before_action :set_field, only: %i[show edit update destroy]
  before_action :set_field_page_layout, only: %i[index new create show edit update]

  def index
    @fields = @form.fields.order(position: :asc)
  end

  def new
    @_breadcrumbs << { text: "New" }
    @field = @form.fields.build
  end

  def edit
    @_breadcrumbs << { text: "Edit" }
  end

  def create
    @field = @form.fields.build(field_params)

    if @field.save
      redirect_to form_fields_url(@form), notice: "Field was successfully created."
    else
      @_breadcrumbs << { text: "New" }
      render :new
    end
  end

  def update
    if @field.update(field_params)
      redirect_to form_fields_url(@form), notice: "Field was successfully updated."
    else
      @_breadcrumbs << { text: "Edit" }
      render :edit
    end
  end

  def destroy
    @field.destroy
    redirect_to form_fields_url(@form), notice: "Field was successfully destroyed."
  end

  def move
    @field = @form.fields.find(params[:field_id])
    if @field && params[:position].present?
      index = params[:position].to_i
      @field.insert_at(index)
    end

    head :no_content
  end

  private

    def set_field
      @field = @form.fields.find(params[:id])
    end

    def set_field_page_layout
      @_breadcrumbs << { text: "Fields", link: form_fields_path(@form) }
      if @field
        @_breadcrumbs << { text: @field.name }
      end
    end

    def field_params
      params.fetch(:field, {}).permit(:key, :name, :hint, :type)
    end
end
