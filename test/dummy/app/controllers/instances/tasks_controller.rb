# frozen_string_literal: true

class Instances::TasksController < Instances::ApplicationController
  before_action :set_task, only: %i[finish]

  def finish
    unless @task.can_finish?
      redirect_to instance_url(@instance), notice: "Task can not finish."
      return
    end

    @task.finish!

    redirect_to instance_url(@instance), notice: "Task finished."
  end

  private

    def set_task
      @task = @instance.tasks.find(params[:id])
    end
end
