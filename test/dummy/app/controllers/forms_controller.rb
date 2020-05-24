# frozen_string_literal: true

class FormsController < ApplicationController
  before_action :set_form, only: %i[show edit update destroy]
  before_action :set_form_layout_data, only: %i[show edit update]

  # GET /forms
  def index
    @forms = FormKit::Form.all
  end

  # GET /forms/new
  def new
    @form = FormKit::Form.new
  end

  def show
    redirect_to form_fields_url(@form)
  end

  # GET /forms/1/edit
  def edit
    @_breadcrumbs << { text: "Edit" }
  end

  # POST /forms
  def create
    @form = FormKit::Form.new(form_params)

    if @form.save
      redirect_to form_fields_url(@form), notice: "Form was successfully created."
    else
      render :new
    end
  end

  # PATCH/PUT /forms/1
  def update
    if @form.update(form_params)
      redirect_to form_fields_url(@form), notice: "Form was successfully updated."
    else
      @_breadcrumbs << { text: "Edit" }
      render :edit
    end
  end

  # DELETE /forms/1
  def destroy
    @form.destroy
    redirect_to forms_url, notice: "Form was successfully destroyed."
  end

  def random
    @form = FormKit::Form.create_random_form!

    redirect_to form_fields_url(@form), notice: "Form was successfully generated."
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_form
      @form = FormKit::Form.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def form_params
      params.fetch(:form, {}).permit(:key, :name)
    end

    def set_form_layout_data
      @_breadcrumbs =
        [
          { text: "Forms", link: forms_path },
          { text: @form.name, link: form_path(@form) }
        ]
    end
end
