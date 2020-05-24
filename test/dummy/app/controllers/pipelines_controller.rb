# frozen_string_literal: true

class PipelinesController < ApplicationController
  before_action :set_pipeline, only: %i[show edit update destroy deploy]

  def index
    @pipelines = FlowKit::BusinessPipeline.all
  end

  def show; end

  def new
    @pipeline = FlowKit::BusinessPipeline.new
  end

  def edit; end

  def create
    @pipeline = FlowKit::BusinessPipeline.new(pipeline_params)

    if @pipeline.save
      redirect_to pipeline_url(@pipeline), notice: "Pipeline was successfully created."
    else
      render :new
    end
  end

  def update
    if @pipeline.update(pipeline_params)
      redirect_to pipeline_url(@pipeline), notice: "Pipeline was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @pipeline.destroy
    redirect_to pipelines_url, notice: "Pipeline was successfully destroyed."
  end

  def deploy
    workflow = @pipeline.deploy_workflow # rescue nil

    if workflow
      redirect_to workflow_url(workflow)
    else
      redirect_to pipeline_url(@pipeline)
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_pipeline
      @pipeline = FlowKit::BusinessPipeline.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def pipeline_params
      params.require(:pipeline).permit(:name, :form_id)
    end
end
