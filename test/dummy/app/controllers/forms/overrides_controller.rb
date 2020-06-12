# frozen_string_literal: true

class Forms::OverridesController < Forms::ApplicationController
  before_action :set_override, only: %i[edit update destroy]
  before_action :set_override_page_layout, only: %i[index new create show edit update]

  def index
    @overrides = @form.overrides.order(position: :asc)
  end

  def new
    @_breadcrumbs << { text: "New" }
    @override = @form.overrides.build
  end

  def edit
    @_breadcrumbs << { text: "Edit" }
  end

  def create
    @override = @form.overrides.build(override_params)

    if @override.save
      redirect_to form_overrides_url(@form), notice: "Override was successfully created."
    else
      @_breadcrumbs << { text: "New" }
      render :new
    end
  end

  def update
    if @override.update(override_params)
      redirect_to form_overrides_url(@form), notice: "Override was successfully updated."
    else
      @_breadcrumbs << { text: "Edit" }
      render :edit
    end
  end

  def destroy
    @override.destroy
    redirect_to form_overrides_url(@form), notice: "Override was successfully destroyed."
  end

  private

    def set_override
      @override = @form.overrides.find(params[:id])
    end

    def set_override_page_layout
      @_breadcrumbs << { text: "Overrides", link: form_overrides_path(@form) }
      if @override
        @_breadcrumbs << { text: @override.name }
      end
    end

    def override_params
      params.fetch(:form_override, {}).permit(:name, field_overrides_attributes: %i[id field_id accessibility])
    end
end
