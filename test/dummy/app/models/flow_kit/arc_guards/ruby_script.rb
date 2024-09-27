# frozen_string_literal: true

module FlowKit::ArcGuards
  class RubyScript < FlowCore::ArcGuard
    serialize :configuration, coder: Configuration

    def permit?(task)
      result = ScriptEngine.run_inline configuration.script, payload: task.payload
      if result.errors.any?
        raise "Script has errored"
      end

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
