# frozen_string_literal: true

FlowCore::Steps::End.class_eval do
  def graphviz_name
    "pipeline_#{pipeline_id}_step_#{id}"
  end

  def graphviz_node(graph, interactive: false)
    if graph.nodes[graphviz_name]
      return graph.nodes[graphviz_name]
    end

    attrs = {
      style: :filled, fillcolor: :white
    }
    attrs[:shape] = multi_branch_step? ? :diamond : :box
    attrs[:label] = multi_branch_step? ? "#{name}_START" : name
    if interactive
      attrs[:href] = Rails.application.routes.url_helpers.edit_pipeline_step_path(pipeline, self)
    end

    Graphviz::Node.new graphviz_name, graph, **attrs
  end

  def append_to_graphviz(graph)
    node = graphviz_node(graph)

    node.connect pipeline.end_graphviz_node(graph)

    [node, nil]
  end

  def append_to_designer_graphviz(graph)
    node = graphviz_node(graph, interactive: true)

    node.connect pipeline.end_graphviz_node(graph)

    [node, nil]
  end
end
