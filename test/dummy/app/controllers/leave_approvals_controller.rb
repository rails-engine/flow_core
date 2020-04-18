# frozen_string_literal: true

class LeaveApprovalsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_workflow
  before_action :set_approval
  before_action :require_assignee!

  def show; end

  def update
    if @approval.finished?
      redirect_to leave_approval_url(@approval)
    end

    if @approval.update_payload params: params.require(:approval)
      @approval.finish
      redirect_to leave_url(@leave)
    else
      render :show
    end
  end

  private

    def set_workflow
      @workflow = LeaveWorkflow.find_or_deploy_leave_flow
    end

    def set_approval
      @approval = HumanTask.where(workflow_tag: @workflow.tag).find(params[:id])
    end

    def require_assignee!
      return if @approval.finished?

      if current_user != @approval.assignee
        redirect_to leave_url(@leave), alert: "You're not the assignee"
      end
    end
end
