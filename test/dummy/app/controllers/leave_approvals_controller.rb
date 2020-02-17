# frozen_string_literal: true

class LeaveApprovalsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_workflow
  before_action :set_approval
  before_action :set_leave
  before_action :require_assignee!

  def show
    case @approval.transition_tag
    when "leader_evaluate"
      show_leader_evaluate
    when "hr_evaluate"
      show_hr_evaluate
    when "report_back"
      show_report_back
    when "resend_request"
      show_resend_request
    else
      raise "Unknown tag #{@approval.transition_tag}"
    end
  end

  def update
    if @approval.finished?
      redirect_to leave_approval_url(@approval)
    end

    case @approval.transition_tag
    when "leader_evaluate"
      update_leader_evaluate
    when "hr_evaluate"
      update_hr_evaluate
    when "report_back"
      update_report_back
    when "resend_request"
      update_resend_request
    else
      raise "Unknown tag #{@approval.transition_tag}"
    end
  end

  private

    def set_workflow
      @workflow = FlowCore::Workflow.find_by!(tag: "leave")
    end

    def set_approval
      @approval = UserTask.where(workflow_tag: @workflow.tag).find(params[:id])
    end

    def show_leader_evaluate
      render "leader_evaluate"
    end

    def update_leader_evaluate
      @approval.assign_attributes(params.require(:approval).permit(:approved, :comment))
      if @approval.valid?
        @approval.finish!
        redirect_to leave_url(@leave)
      else
        render "leader_evaluate"
      end
    end

    def show_hr_evaluate
      render "hr_evaluate"
    end

    def update_hr_evaluate
      @approval.assign_attributes(params.require(:approval).permit(:approved, :comment))
      if @approval.valid?
        @approval.finish!
        @leave.ongoing!
        redirect_to leave_url(@leave)
      else
        render "leader_evaluate"
      end
    end

    def show_resend_request
      render "resend_request"
    end

    def update_resend_request
      if params[:discard].present?
        @approval.set_payload! discard: true
        @approval.finish!
        @leave.obsoleted!
        redirect_to leave_url(@leave)
        return
      end

      leave_params = params.require(:leave).permit(:start_date, :end_date, :reason)
      if @leave.update!(leave_params)
        @approval.set_payload! discard: false
        @approval.finish!
        redirect_to leave_url(@leave)
      else
        render "resend_request"
      end
    end

    def show_report_back
      render "report_back"
    end

    def update_report_back
      @approval.assign_attributes(params.require(:approval).permit(:comment))
      if @approval.valid?
        @approval.finish!
        @leave.finished!
        redirect_to leave_url(@leave)
      else
        render "report_back"
      end
    end

    def set_or_initialize_workflow
      @workflow = InternalWorkflow.find_or_deploy_leave_flow
    end

    def set_leave
      @leave = Leave.find(@approval.task.instance_payload.fetch(:leave_id))
    end

    def require_assignee!
      return if @approval.finished?

      if current_user != @approval.assignee
        redirect_to leave_url(@leave), alert: "You're not the assignee"
      end
    end
end
