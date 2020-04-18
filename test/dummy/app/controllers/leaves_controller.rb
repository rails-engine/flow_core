# frozen_string_literal: true

class LeavesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_leave, only: %i[show edit update destroy initiate]

  # GET /leaves
  def index
    @leaves = Leave.all
  end

  # GET /leaves/1
  def show
    @approvals = @leave.workflow_instance&.tasks&.includes(:transition, executable: [:assignee]) || ApplicationRecord.none
  end

  # GET /leaves/new
  def new
    @leave = Leave.new
  end

  # GET /leaves/1/edit
  def edit; end

  # POST /leaves
  def create
    @leave = current_user.leaves.new(leave_params)

    if @leave.save
      redirect_to @leave, notice: "Leave was successfully created."
    else
      render :new
    end
  end

  # PATCH/PUT /leaves/1
  def update
    if @leave.update(leave_params)
      redirect_to @leave, notice: "Leave was successfully updated."
    else
      render :edit
    end
  end

  # DELETE /leaves/1
  def destroy
    @leave.destroy
    redirect_to leaves_url, notice: "Leave was successfully destroyed."
  end

  def initiate
    workflow = LeaveWorkflow.find_or_deploy_leave_flow
    instance = workflow.build_instance creator: current_user, leave: @leave
    instance.save!
    instance.activate!
    @leave.update! workflow_instance: instance, stage: :evaluating

    redirect_to leave_url(@leave), notice: "Leave workflow activated."
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_leave
      @leave = Leave.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def leave_params
      params.require(:leave).permit(:start_date, :end_date, :reason)
    end
end
