# frozen_string_literal: true

class Pipelines::Steps::TransitionTriggersController < Pipelines::Steps::ApplicationController
  before_action :set_transition_trigger, only: %i[show edit update destroy]

  def new
    trigger_type = FlowCore::TransitionTrigger.descendants.map(&:to_s).include?(params[:type]) ? params[:type] : nil
    if trigger_type
      @transition_trigger = @step.build_transition_trigger type: trigger_type
    end
  end

  def create
    @transition_trigger = @step.build_transition_trigger transition_trigger_params
    if @transition_trigger.save
      redirect_to edit_pipeline_step_url(@pipeline, @step), notice: "Transition trigger created."
    else
      render :new
    end
  end

  def show
    redirect_to edit_pipeline_step_transition_trigger_url(@pipeline, @step)
  end

  def edit; end

  def update
    if @transition_trigger.update transition_trigger_params
      redirect_to edit_pipeline_step_url(@pipeline, @step), notice: "Transition trigger updated."
    else
      render :edit
    end
  end

  def destroy
    @transition_trigger.destroy
    redirect_to edit_pipeline_step_url(@pipeline, @step), notice: "Transition trigger destroyed."
  end

  private

    def set_transition_trigger
      @transition_trigger = @step.transition_trigger
    end

    def transition_trigger_params
      params.require(:transition_trigger).permit(:type, assignee_candidate_user_ids: [], configuration: {})
    end
end
