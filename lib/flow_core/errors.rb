# frozen_string_literal: true

module FlowCore
  # Generic base class for all Workflow Core exceptions.
  class Error < StandardError; end

  class UnverifiedWorkflow < Error; end

  class InvalidTransition < Error; end

  class NoNewTokenCreated < Error; end

  class ForbiddenOperation < Error; end
end
