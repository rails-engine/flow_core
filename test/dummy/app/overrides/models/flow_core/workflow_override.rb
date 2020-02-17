# frozen_string_literal: true

FlowCore::Workflow.class_eval do
  def internal?
    false
  end

  def to_graph(instance: nil)
    graph = GraphViz.new(name, type: :digraph, rankdir: "LR", splines: true, ratio: :auto)
    free_token_places =
      if instance
        instance.tokens.where(stage: %i[free locked]).map(&:place_id)
      else
        []
      end

    pg_mapping = {}
    places.order(id: :asc).each do |p|
      if p.start?
        fillcolor = :yellow
        shape     = :doublecircle
      elsif p.end?
        fillcolor = :green
        shape     = :doublecircle
      else
        fillcolor = :lightpink
        shape     = :circle
      end

      token_count = free_token_places.count(p.id)
      label = token_count.positive? ? "&bull;" * token_count : ""
      xlabel = p.name

      pg = graph.add_nodes p.name, xlabel: xlabel, label: label, shape: shape, fixedsize: true, style: :filled, fillcolor: fillcolor
      pg_mapping[p] = pg
    end

    tg_mapping = {}
    transitions.each do |t|
      tg = graph.add_nodes t.name, label: t.name, shape: :box, style: :filled, fillcolor: :lightblue
      tg_mapping[t] = tg
    end

    arcs.order("direction desc").each do |arc|
      label =
        if arc.guards.size.positive?
          arc.guards.map(&:description).join(" & ")
        else
          ""
        end
      if arc.in?
        graph.add_edges(
          pg_mapping[arc.place],
          tg_mapping[arc.transition],
          label: label,
          weight: 1,
          labelfloat: false,
          labelfontcolor: :red,
          arrowhead: :vee
        )
      else
        graph.add_edges(
          tg_mapping[arc.transition],
          pg_mapping[arc.place],
          label: label,
          weight: 1,
          labelfloat: false,
          labelfontcolor: :red,
          arrowhead: :vee
        )
      end
    end
    graph
  end
end
