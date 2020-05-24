# frozen_string_literal: true

class Pipelines::StepsController < Pipelines::ApplicationController
  before_action :set_step, only: %i[show edit update destroy]

  def new
    @step = @pipeline.steps.new
    @step.append_to = params[:append_to]
  end

  def create
    @step = @pipeline.steps.new(step_params)

    if @step.save
      redirect_to edit_pipeline_step_url(@pipeline, @step), notice: "Step was successfully created."
    else
      render :new
    end
  end

  def show
    redirect_to edit_pipeline_step_url(@pipeline, @step)
  end

  def edit; end

  def update
    if @step.update(step_params)
      redirect_to pipeline_url(@pipeline), notice: "Step was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @step.destroy

    redirect_to pipeline_url(@pipeline), notice: "Step was successfully destroyed."
  end

  def move
    step = @pipeline.steps.find(params[:step_id])
    if step && params[:position].present?
      index = params[:position].to_i
      step.insert_at(index)
    end

    head :no_content
  end

  private

    def set_step
      @step = @pipeline.whole_steps.find(params[:id])
    end

    def step_params
      params.require(:step).permit(:name, :type, :append_to)
    end
end
