# frozen_string_literal: true

module FlowKit::ArcGuards
  class RubyScript < FlowCore::ArcGuard
    serialize :configuration, Configuration

    def permit?(task)
      result = ScriptEngine.run_inline script, payload: task.payload
      # TODO: May error
      result.output
    end

    def description
      configuration.name
    end

    def configurable?
      true
    end
  end
end
