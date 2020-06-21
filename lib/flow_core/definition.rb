# frozen_string_literal: true

require "flow_core/definition/place"
require "flow_core/definition/transition"
require "flow_core/definition/net"
require "flow_core/definition/trigger"
require "flow_core/definition/guard"

module FlowCore::Definition
  class << self
    def build(attributes = {}, &block)
      FlowCore::Definition::Net.new(attributes, &block)
    end
    alias new build
  end
end
