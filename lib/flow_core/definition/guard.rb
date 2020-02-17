# frozen_string_literal: true

module FlowCore::Definition
  class Guard
    def initialize(attributes)
      constant_or_klass = attributes.is_a?(Hash) ? attributes.delete(:type) : attributes
      @klass =
        if constant_or_klass.is_a? String
          constant_or_klass.safe_constantize
        else
          constant_or_klass
        end
      unless @klass && @klass < FlowCore::ArcGuard
        raise TypeError, "First argument expect `FlowCore::TransitionTrigger` subclass or its constant name - #{constant_or_klass}"
      end

      @configuration = attributes.is_a?(Hash) ? attributes : nil
    end

    def compile
      if @configuration&.any?
        {
          type: @klass.to_s,
          configuration: @configuration
        }
      else
        {
          type: @klass.to_s
        }
      end
    end
  end
end
