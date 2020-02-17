# frozen_string_literal: true

class WorkflowsController < ApplicationController
  before_action :set_workflow, only: %i[show edit update destroy verify]

  def index
    @workflows = FlowCore::Workflow.all
  end

  def show; end

  def new
    @workflow = FlowCore::Workflow.new
  end

  def edit; end

  def create
    @workflow = FlowCore::Workflow.new(workflow_params)

    if @workflow.save
      redirect_to workflow_path(@workflow), notice: "Workflows was successfully created."
    else
      render :new
    end
  end

  def update
    if @workflow.update(workflow_params)
      redirect_to workflow_path(@workflow), notice: "Workflows was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @workflow.destroy
    redirect_to workflows_url, notice: "Workflows was successfully destroyed."
  end

  def verify
    @workflow.verify!
    redirect_to workflow_path(@workflow)
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_workflow
      @workflow = FlowCore::Workflow.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def workflow_params
      params.require(:workflow).permit(:name)
    end
end
