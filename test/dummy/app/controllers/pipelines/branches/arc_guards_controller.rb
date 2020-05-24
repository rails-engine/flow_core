# frozen_string_literal: true

class Pipelines::Branches::ArcGuardsController < Pipelines::Branches::ApplicationController
  before_action :set_arc_guard, only: %i[show edit update destroy]

  def new
    guard_type = FlowCore::ArcGuard.descendants.map(&:to_s).include?(params[:type]) ? params[:type] : nil
    if guard_type
      @arc_guard = @branch.arc_guards.new type: guard_type
    end
  end

  def create
    @arc_guard = @branch.arc_guards.new arc_guard_params
    if @arc_guard.save!
      redirect_to edit_pipeline_branch_url(@pipeline, @branch), notice: "Arc guard created."
    else
      render :new
    end
  end

  def show
    redirect_to edit_pipeline_branch_arc_guard_url(@pipeline, @branch, @arc_guard)
  end

  def edit; end

  def update
    if @arc_guard.update arc_guard_params
      redirect_to edit_pipeline_branch_url(@pipeline, @branch), notice: "Arc guard updated."
    else
      render :edit
    end
  end

  def destroy
    @arc_guard.destroy
    redirect_to edit_pipeline_branch_url(@pipeline, @branch), notice: "Arc guard destroyed."
  end

  private

    def set_arc_guard
      @arc_guard = @branch.arc_guards.find(params[:id])
    end

    def arc_guard_params
      params.require(:arc_guard).permit(:type, configuration: {})
    end
end
