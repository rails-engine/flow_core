# frozen_string_literal: true

class InstancesController < ApplicationController
  before_action :set_instance, only: %i[show active]

  def index
    @instances = FlowCore::Instance.all.includes(:workflow)
  end

  def show
    @tasks = @instance.tasks.includes(:transition)
  end

  def active
    unless @instance.can_active?
      redirect_to instance_url(@instance), notice: "Instance can not active."
      return
    end

    @instance.active!

    redirect_to instance_url(@instance), notice: "Instance activated."
  end

  private

    def set_instance
      @instance = FlowCore::Instance.find(params[:id])
    end
end
