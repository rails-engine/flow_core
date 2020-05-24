# frozen_string_literal: true

class Fields::ChoicesController < Fields::ApplicationController
  before_action :require_attach_choices!
  before_action :set_choice, only: %i[edit update destroy]
  before_action :set_page_layout

  def new
    @_breadcrumbs << { text: "New" }
    @choice = @field.choices.build
  end

  def create
    @choice = @field.choices.build choice_params
    if @choice.save
      redirect_to field_choices_url(@field)
    else
      @_breadcrumbs << { text: "New" }
      render :new
    end
  end

  def edit
    @_breadcrumbs << { text: "Edit" }
  end

  def update
    if @choice.update choice_params
      redirect_to field_choices_url(@field)
    else
      @_breadcrumbs << { text: "Edit" }
      render :edit
    end
  end

  def destroy
    @choice.destroy
    redirect_to field_choices_url(@field)
  end

  private

    def require_attach_choices!
      unless @field.attached_choices?
        redirect_to fields_url
      end
    end

    def set_choice
      @choice = @field.choices.find(params[:id])
    end

    def set_page_layout
      @_breadcrumbs << { text: "Choices", link: field_choices_path(@field) }
      if @choice
        @_breadcrumbs << { text: @choice.label }
      end
    end

    def choice_params
      params.require(:choice).permit(:label)
    end
end
