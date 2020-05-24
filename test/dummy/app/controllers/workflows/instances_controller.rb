# frozen_string_literal: true

class Workflows::InstancesController < Workflows::ApplicationController
  def new
    if @workflow.type.blank?
      @instance = @workflow.instances.create!
      redirect_to instance_url(@instance), notice: "Instance created."
      return
    end

    @instance = @workflow.instances.new
    @payload_model = @workflow.form.to_virtual_model
    @payload = @payload_model.new
  end

  def create
    @instance = @workflow.instances.new instance_params
    @instance.creator = current_user

    @payload_model = @workflow.form.to_virtual_model
    @payload = @payload_model.new @instance.payload

    if @payload.valid? && @instance.save
      redirect_to instance_url(@instance), notice: "Instance created."
    else
      render :new
    end
  end

  private

    def instance_params
      params.require(:instance).permit(payload: {})
    end
end
