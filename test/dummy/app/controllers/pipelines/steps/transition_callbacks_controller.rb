# frozen_string_literal: true

class Pipelines::Steps::TransitionCallbacksController < Pipelines::Steps::ApplicationController
  before_action :set_transition_callback, only: %i[show edit update destroy]

  def new
    callback_type = FlowCore::TransitionCallback.descendants.map(&:to_s).include?(params[:type]) ? params[:type] : nil
    if callback_type
      @transition_callback = @step.transition_callbacks.new type: callback_type
    end
  end

  def create
    @transition_callback = @step.transition_callbacks.new transition_callback_params
    if @transition_callback.save
      redirect_to edit_pipeline_step_url(@pipeline, @step), notice: "Transition callback created."
    else
      render :new
    end
  end

  def show
    redirect_to edit_pipeline_step_transition_callback_url(@pipeline, @step, @transition_callback)
  end

  def edit; end

  def update
    if @transition_callback.update transition_callback_params
      redirect_to edit_pipeline_step_url(@pipeline, @step), notice: "Transition callback updated."
    else
      render :edit
    end
  end

  def destroy
    @transition_callback.destroy
    redirect_to edit_pipeline_step_url(@pipeline, @step), notice: "Transition callback destroyed."
  end

  private

    def set_transition_callback
      @transition_callback = @step.transition_callbacks.find(params[:id])
    end

    def transition_callback_params
      params.require(:transition_callback).permit(:type, configuration: {})
    end
end
