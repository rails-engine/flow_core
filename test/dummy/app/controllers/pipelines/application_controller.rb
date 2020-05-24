# frozen_string_literal: true

class Pipelines::ApplicationController < ::ApplicationController
  before_action :set_pipeline

  protected

    def set_pipeline
      @pipeline = FlowKit::BusinessPipeline.find(params[:pipeline_id])
    end
end
