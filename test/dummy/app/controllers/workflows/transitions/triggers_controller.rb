# frozen_string_literal: true

class Workflows::Transitions::TriggersController < Workflows::Transitions::ApplicationController
  before_action :set_trigger, only: %i[edit update destroy]

  def new
    trigger_type = FlowCore::TransitionTrigger.descendants.map(&:to_s).include?(params[:type]) ? params[:type] : nil
    if trigger_type
      @trigger = @transition.build_trigger type: trigger_type
    end
  end

  def create
    @trigger = @transition.build_trigger trigger_params
    if @trigger.save
      redirect_to workflow_transition_url(@workflow, @transition), notice: "Transition trigger created."
    else
      render :new
    end
  end

  def edit; end

  def update
    if @trigger.update trigger_params
      redirect_to workflow_transition_url(@workflow, @transition), notice: "Transition trigger updated."
    else
      render :edit
    end
  end

  def destroy
    @trigger.destroy
    redirect_to workflow_transiton_url(@workflow, @transition)
  end

  private

    def set_trigger
      @trigger = @transition.trigger
    end

    def trigger_params
      params.require(:trigger).permit(:type, assignee_candidate_user_ids: [], configuration: {})
    end
end
