# frozen_string_literal: true

class Pipelines::BranchesController < Pipelines::ApplicationController
  before_action :set_branch, only: %i[show edit update destroy]

  def show; end

  def edit; end

  def update
    if @branch.update(branch_params)
      redirect_to edit_pipeline_step_url(@pipeline, @branch.step), notice: "Branch was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @branch.destroy

    redirect_to edit_pipeline_step_url(@pipeline, @branch.step), notice: "Branch was successfully destroyed."
  end

  private

    def set_branch
      @branch = @pipeline.branches.find(params[:id])
    end

    def branch_params
      params.require(:branch).permit(:name)
    end
end
