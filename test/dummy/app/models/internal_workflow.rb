# frozen_string_literal: true

class InternalWorkflow < FlowCore::Workflow
  def internal?
    true
  end
end
