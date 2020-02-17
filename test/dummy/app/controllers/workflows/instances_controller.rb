# frozen_string_literal: true

class Workflows::InstancesController < Workflows::ApplicationController
  def new; end

  def create
    @instance = @workflow.instances.create!

    redirect_to instance_url(@instance), notice: "Instance created."
  end
end
