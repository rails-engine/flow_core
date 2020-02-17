# frozen_string_literal: true

class Workflows::TransitionsController < Workflows::ApplicationController
  before_action :set_transition, only: %i[show update]

  def show; end

  def update
    if @transition.update transition_params
      redirect_to workflow_transition_url(@workflow, @transition), notice: "Transition updated."
    else
      render :show
    end
  end

  private

    def set_transition
      @transition = @workflow.transitions.find(params[:id])
    end

    def transition_params
      params.require(:transition).permit(:name, :handler_class_name)
    end
end
