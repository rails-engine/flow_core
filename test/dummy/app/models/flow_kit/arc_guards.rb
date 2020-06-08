# frozen_string_literal: true

module FlowKit::ArcGuards
  def self.all_types
    @all_types ||= [
      FlowKit::ArcGuards::RubyScript,
    ]
  end
end
