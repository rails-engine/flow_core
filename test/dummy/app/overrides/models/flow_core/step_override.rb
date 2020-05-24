# frozen_string_literal: true

FlowCore::Step.class_eval do
  def graphviz_name
    "pipeline_#{pipeline_id}_step_#{id}"
  end

  def graphviz_node(graph, interactive: false)
    if graph.nodes[graphviz_name]
      return graph.nodes[graphviz_name]
    end

    attrs = {
      label: name, style: :filled, fillcolor: :white
    }
    attrs[:shape] = multi_branch_step? ? :diamond : :box
    attrs[:color] = verified? ? :black : :red
    if interactive
      attrs[:href] = Rails.application.routes.url_helpers.edit_pipeline_step_path(pipeline, self)
    end

    Graphviz::Node.new graphviz_name, graph, attrs
  end

  def graphviz_node_for_append(graph)
    append_node_name = "append_to_#{graphviz_name}"
    if graph.nodes[append_node_name]
      return graph.nodes[append_node_name]
    end

    href =
      if branch
        Rails.application.routes.url_helpers.new_pipeline_branch_step_path(pipeline, branch, append_to: id)
      else
        Rails.application.routes.url_helpers.new_pipeline_step_path(pipeline, append_to: id)
      end

    Graphviz::Node.new append_node_name, graph,
                       label: "+", shape: :box, style: "filled,dotted", fillcolor: :white,
                       href: href
  end

  def append_to_designer_graphviz(graph)
    node = graphviz_node(graph, interactive: true)

    if multi_branch_step?
      append_node = graphviz_node_for_append(graph)
      end_node = Graphviz::Node.new "#{graphviz_name}_END", graph,
                                    shape: :point, style: :filled, fillcolor: :white
      new_branch_node =
        Graphviz::Node.new "new_branch_for_#{graphviz_name}", graph,
                           label: "+", shape: :box, style: "rounded,filled,dotted", fillcolor: :white,
                           href: Rails.application.routes.url_helpers.new_pipeline_step_branch_path(pipeline, self)
      node.connect new_branch_node, style: :dotted, arrowhead: :none
      new_branch_node.connect end_node, style: :dotted, arrowhead: :none
      end_node.connect append_node, arrowhead: :none

      branches.each do |branch|
        _sub_graph, first_node, last_node = branch.to_designer_graphviz(graph)
        node.connect first_node, arrowhead: :none, style: branch.fallback_branch? ? "bold" : ""

        last_node&.connect end_node, arrowhead: :none
      end

      [node, append_node]
    elsif redirection_step?
      if redirect_to_step
        node.connect redirect_to_step.graphviz_node(graph)
      end

      [node, nil]
    else
      append_node = graphviz_node_for_append(graph)
      node.connect append_node, arrowhead: :none

      [node, append_node]
    end
  end

  def append_to_graphviz(graph)
    node = graphviz_node(graph)

    if multi_branch_step? && branches.any?
      end_node = Graphviz::Node.new "#{graphviz_name}_END", graph,
                                    shape: :point, style: :filled, fillcolor: :white
      end_node_connected = false
      branches.each do |branch|
        _sub_graph, first_node, last_node = branch.to_graphviz(graph)
        node.connect first_node, arrowhead: :none, style: branch.fallback_branch? ? "bold" : ""

        if last_node
          end_node_connected = true
          last_node.connect end_node, arrowhead: :none
        end
      end

      if end_node_connected
        [node, end_node]
      else
        [node, node]
      end
    elsif redirection_step?
      if redirect_to_step
        node.connect redirect_to_step.graphviz_node(graph)
      end

      [node, nil]
    else
      [node, node]
    end
  end
end
