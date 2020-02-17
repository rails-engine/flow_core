# frozen_string_literal: true

module ArcGuards
  class Dentaku < FlowCore::ArcGuard
    serialize :configuration, Configuration

    def permit?(task)
      Dentaku!(configuration.expression, task.payload)
    end

    def description
      configuration.name
    end
  end
end
