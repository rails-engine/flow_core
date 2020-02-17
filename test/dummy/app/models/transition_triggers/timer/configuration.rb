# frozen_string_literal: true

module TransitionTriggers
  class Timer
    class Configuration < SerializableConfiguration
      attribute :countdown_in_seconds, :integer, default: 0

      validates :countdown_in_seconds,
                numericality: {
                  only_integer: true,
                  greater_than_or_equal_to: 0
                }
    end
  end
end
