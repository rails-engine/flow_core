# frozen_string_literal: true

class HumanTasksController < ApplicationController
  before_action :set_human_task

  def show; end

  def update
    if @human_task.fill_form!(human_task_params.fetch(:form_record, {}))
      @human_task.finish!

      redirect_to instance_url(@human_task.instance), notice: "Task finished."
    else
      render :show
    end
  end

  private

    def set_human_task
      @human_task = FlowKit::HumanTask.find(params[:id])
    end

    def human_task_params
      params.fetch(:human_task, {}).permit(form_record: {})
    end
end
