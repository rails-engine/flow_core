# frozen_string_literal: true

class Workflows::ApplicationController < ::ApplicationController
  before_action :set_workflow

  protected

    def set_workflow
      @workflow = FlowCore::Workflow.find(params[:workflow_id])
    end
end
