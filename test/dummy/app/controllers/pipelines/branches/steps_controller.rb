# frozen_string_literal: true

class Pipelines::Branches::StepsController < Pipelines::Branches::ApplicationController
  def new
    @step = @branch.steps.new
    @step.append_to = params[:append_to]
  end

  def create
    @step = @branch.steps.new(step_params)

    if @step.save
      redirect_to pipeline_branch_url(@pipeline, @branch), notice: "Step was successfully created."
    else
      render :new
    end
  end

  def move
    step = @branch.steps.find(params[:step_id])
    if step && params[:position].present?
      index = params[:position].to_i
      step.insert_at(index)
    end

    head :no_content
  end

  private

    def step_params
      params.require(:step).permit(:name, :type, :append_to)
    end
end
