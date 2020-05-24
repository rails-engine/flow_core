# frozen_string_literal: true

class Pipelines::Steps::BranchesController < Pipelines::Steps::ApplicationController
  def new
    @branch = @step.branches.new
  end

  def create
    @branch = @step.branches.new(branch_params)

    if @branch.save
      redirect_to pipeline_branch_url(@pipeline, @branch), notice: "Branch was successfully created."
    else
      render :new
    end
  end

  private

    def branch_params
      params.require(:branch).permit(:name, :type)
    end
end
