# frozen_string_literal: true

class Pipelines::Steps::RedirectionsController < Pipelines::Steps::ApplicationController
  def show
    redirect_to edit_pipeline_step_redirection_url(@pipeline, @step)
  end

  def edit; end

  def update
    if @step.update(step_params)
      redirect_to edit_pipeline_step_url(@pipeline, @step), notice: "Redirection step was successfully updated."
    else
      render :edit
    end
  end

  private

    def step_params
      params.require(:step).permit(:redirect_to_step_id)
    end
end
