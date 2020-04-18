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

    def _call(_task, *_args)
      raise NotImplementedError
    end

    def call(task, *args)
      return unless on.include? task.stage.to_sym
      return unless callable? task

      _call task, *args
    end
  end
end
