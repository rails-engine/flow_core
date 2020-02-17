# frozen_string_literal: true

class Instances::ApplicationController < ::ApplicationController
  before_action :set_instance

  protected

    def set_instance
      @instance = FlowCore::Instance.find(params[:instance_id])
    end
end
