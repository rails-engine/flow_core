# frozen_string_literal: true

require "rgl/adjacency"
require "rgl/dijkstra"
require "rgl/topsort"
require "rgl/traversal"
require "rgl/path"

require "flow_core/engine"

require "flow_core/errors"
require "flow_core/arc_guardable"
require "flow_core/transition_triggerable"
require "flow_core/transition_callbackable"
require "flow_core/task_executable"

require "flow_core/definition"
require "flow_core/violations"

ActiveSupport.on_load(:i18n) do
  I18n.load_path << File.expand_path("flow_core/locale/en.yml", __dir__)
end

module FlowCore
end
