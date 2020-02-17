# frozen_string_literal: true

class Workflows::TransitionTriggersController < Workflows::ApplicationController
  before_action :set_trigger, only: %i[edit update]

  def edit; end

  def update
    if @transition_trigger.update transition_trigger_params
      redirect_back fallback_location: edit_workflow_transition_trigger_url(@workflow, @transition_trigger),
                    notice: "Transition trigger updated."
    else
      render :edit
    end
  end

  private

    def set_trigger
      @transition_trigger = FlowCore::TransitionTrigger.where(workflow: @workflow).find(params[:id])
    end

    def transition_trigger_params
      params.require(:transition_trigger).permit(:name, configuration: {})
    end
end
