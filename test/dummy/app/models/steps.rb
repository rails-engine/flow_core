# frozen_string_literal: true

module Steps
  def self.creatable_types
    @creatable_types ||= [
      FlowCore::Steps::Task,
      FlowCore::Steps::ParallelSplit,
      FlowCore::Steps::ExclusiveChoice,
      FlowCore::Steps::Redirection,
      FlowCore::Steps::End
    ]
  end
end
