# frozen_string_literal: true

class Pipelines::Steps::ApplicationController < Pipelines::ApplicationController
  before_action :set_step

  protected

    def set_step
      @step = @pipeline.whole_steps.find(params[:step_id])
    end
end
