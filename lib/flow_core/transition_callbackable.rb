# frozen_string_literal: true

module FlowCore
  module TransitionCallbackable
    extend ActiveSupport::Concern

    included do
      private :_call
    end

    # Should in
    # :created, :enabled, :finished, :terminated,
    # :errored, :rescued :suspended, :resumed
    def on
      []
    end

    def callable?(_task)
      true
    end

    def _call(_task)
      raise NotImplementedError
    end

    def call(task)
      return unless on.include? task.stage.to_sym
      return unless callable? task

      _call task
    end
  end
end
