# frozen_string_literal: true

FlowCore::Pipeline.class_eval do
  def start_graphviz_node(graph)
    if graph.nodes["start"]
      return graph.nodes["start"]
    end

    attrs = {
      label: "Start", shape: :circle, style: :filled, fillcolor: :white
    }

    Graphviz::Node.new "start", graph, **attrs
  end

  def end_graphviz_node(graph)
    if graph.nodes["end"]
      return graph.nodes["end"]
    end

    attrs = {
      label: "End", shape: :circle, style: :filled, fillcolor: :white
    }

    Graphviz::Node.new "end", graph, **attrs
  end

  def to_designer_graphviz
    graph = Graphviz::Graph.new(rankdir: "TB", splines: :splines, ratio: :auto)

    start_node = start_graphviz_node(graph)
    end_node = end_graphviz_node(graph)
    node = Graphviz::Node.new "append_to_start", graph,
                              label: "+", shape: :box, style: "filled,dotted", fillcolor: :white,
                              href: Rails.application.routes.url_helpers.new_pipeline_step_path(self, append_to: "start")
    start_node.connect node

    nodes = steps.map do |step|
      step.append_to_designer_graphviz(graph)
    end
    nodes.reduce(nil) do |memo, (first_node, last_node)|
      memo&.connect first_node
      last_node
    end
    if nodes.any?
      node.connect nodes.first[0], weight: 1
      nodes.last[1].connect end_node, weight: 1
    else
      node.connect end_node, weight: 1
    end

    graph
  end

  def to_graphviz
    graph = Graphviz::Graph.new(rankdir: "TB", splines: :splines, ratio: :auto)

    nodes = steps.map do |step|
      step.append_to_graphviz(graph)
    end
    nodes.reduce(nil) do |memo, (first_node, last_node)|
      memo&.connect first_node
      last_node
    end
    if nodes.any?
      start_graphviz_node(graph).connect nodes.first[0], weight: 1
      nodes.last[1].connect end_graphviz_node(graph), weight: 1
    else
      start_graphviz_node(graph).connect end_graphviz_node(graph), weight: 1
    end

    graph
  end
end
