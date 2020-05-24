# frozen_string_literal: true

class Pipelines::Branches::ApplicationController < Pipelines::ApplicationController
  before_action :set_branch

  protected

    def set_branch
      @branch = @pipeline.branches.find(params[:branch_id])
    end
end
