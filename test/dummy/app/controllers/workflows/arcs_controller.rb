# frozen_string_literal: true

class Workflows::ArcsController < Workflows::ApplicationController
  before_action :set_arc, only: %i[edit update]

  def edit; end

  def update
    if @arc.update arc_params
      redirect_back fallback_location: workflow_transition_url(@workflow, @arc.transition), notice: "Arc updated."
    else
      render :edit
    end
  end

  private

    def set_arc
      @arc = @workflow.arcs.out.find(params[:id])
    end

    def arc_params
      params.require(:arc).permit!
    end
end
