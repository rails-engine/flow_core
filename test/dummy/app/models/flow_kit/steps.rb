# frozen_string_literal: true

module FlowKit::Steps
  def self.all_types
    @all_types ||= [
      FlowCore::Steps::Task,
      FlowCore::Steps::ParallelSplit,
      FlowCore::Steps::ExclusiveChoice,
      FlowCore::Steps::Redirection,
      FlowCore::Steps::End
    ]
  end
end
