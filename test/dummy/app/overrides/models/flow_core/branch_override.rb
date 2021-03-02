# frozen_string_literal: true

FlowCore::Branch.class_eval do
  def graphviz_name
    "pipeline_#{pipeline_id}_step_#{step_id}_branch_#{id}"
  end

  def graphviz_node(graph, interactive: false)
    if graph.nodes[graphviz_name]
      return graph.nodes[graphviz_name]
    end

    attrs = {
      label: name, shape: :box, style: "rounded,filled", fillcolor: :white
    }
    if interactive
      attrs[:href] = Rails.application.routes.url_helpers.edit_pipeline_branch_path(pipeline, self)
    end

    Graphviz::Node.new graphviz_name, graph, **attrs
  end

  def graphviz_node_for_append(graph)
    append_node_name = "append_to_#{graphviz_name}"
    if graph.nodes[append_node_name]
      return graph.nodes[append_node_name]
    end

    Graphviz::Node.new append_node_name, graph,
                       label: "+", shape: :box, style: "filled,dotted", fillcolor: :white,
                       href: Rails.application.routes.url_helpers.new_pipeline_branch_step_path(pipeline, self, append_to: "start")
  end

  def to_designer_graphviz(parent_graph)
    graph_attrs = {
      rankdir: "TB", splines: :line, ratio: :auto
    }
    if parent_graph
      graph_attrs[:compound] = true
      graph_attrs[:style] = :invis
    end

    graph = Graphviz::Graph.new "cluster_#{graphviz_name}", parent_graph, **graph_attrs

    branch_node = graphviz_node(graph, interactive: true)
    append_to_branch_start_node = graphviz_node_for_append(graph)
    branch_node.connect append_to_branch_start_node, arrowhead: :none

    nodes = steps.map do |step|
      step.append_to_designer_graphviz(graph)
    end

    if nodes.empty?
      return [graph, branch_node, append_to_branch_start_node]
    end

    nodes.reduce(append_to_branch_start_node) do |memo, (first_node, last_node)|
      memo&.connect first_node
      last_node
    end

    [graph, branch_node, nodes[-1][1]]
  end

  def to_graphviz(parent_graph)
    graph_attrs = {
      rankdir: "TB", splines: :line, ratio: :auto
    }
    if parent_graph
      graph_attrs[:compound] = true
      graph_attrs[:style] = :invis
    end

    graph = Graphviz::Graph.new "cluster_#{graphviz_name}", parent_graph, **graph_attrs

    branch_node = graphviz_node(graph)

    nodes = steps.map do |step|
      step.append_to_graphviz(graph)
    end

    if nodes.empty?
      return [graph, branch_node, branch_node]
    end

    branch_node.connect nodes[0][0]
    nodes.reduce(nil) do |memo, (first_node, last_node)|
      memo&.connect first_node
      last_node
    end

    [graph, branch_node, nodes[-1][1] || branch_node]
  end
end
