# frozen_string_literal: true

class Workflows::Transitions::ApplicationController < Workflows::ApplicationController
  before_action :set_transition

  protected

    def set_transition
      @transition = @workflow.transitions.find(params[:transition_id])
    end
end
