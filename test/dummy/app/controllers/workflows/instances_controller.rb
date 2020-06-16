# frozen_string_literal: true

class Workflows::InstancesController < Workflows::ApplicationController
  def new
    if @workflow.type.blank?
      @instance = @workflow.create_instance!
      redirect_to instance_url(@instance), notice: "Instance created."
      return
    end

    unless current_user
      redirect_to users_url
      return
    end

    @instance = @workflow.build_instance
  end

  def create
    @instance = @workflow.build_instance instance_params
    @instance.creator = current_user

    if @instance.save
      redirect_to instance_url(@instance), notice: "Instance created."
    else
      render :new
    end
  end

  private

    def instance_params
      params.fetch(:instance, {}).permit(form_attributes: {})
    end
end
