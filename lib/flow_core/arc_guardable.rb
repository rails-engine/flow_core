# frozen_string_literal: true

module FlowCore
  module ArcGuardable
    extend ActiveSupport::Concern

    def permit?(_task)
      raise NotImplementedError
    end

    def description
      raise NotImplementedError
    end
  end
end
