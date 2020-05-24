# frozen_string_literal: true

class InstancesController < ApplicationController
  before_action :set_instance, only: %i[show activate]

  def index
    @instances = FlowCore::Instance.all.includes(:workflow)
  end

  def show
    @human_tasks = FlowKit::HumanTask.where(instance: @instance).includes(:assignable)
    @tasks = @instance.tasks.includes(:transition)
  end

  def activate
    unless @instance.can_activate?
      redirect_to instance_url(@instance), notice: "Instance can not activate."
      return
    end

    @instance.activate!

    redirect_to instance_url(@instance), notice: "Instance activated."
  end

  private

    def set_instance
      @instance = FlowCore::Instance.find(params[:id])
    end
end
