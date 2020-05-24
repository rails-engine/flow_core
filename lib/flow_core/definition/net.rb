# frozen_string_literal: true

module FlowCore::Definition
  class Net
    attr_reader :attributes, :places, :transitions, :start_tag, :end_tag

    def initialize(attributes = {})
      @attributes = attributes.with_indifferent_access.except(FlowCore::Workflow::FORBIDDEN_ATTRIBUTES)
      @places = []
      @transitions = []
      @start_tag = nil
      @end_tag = nil

      yield(self)
    end

    def add_place(tag_or_place, attributes = {})
      entity =
        if tag_or_place.is_a? FlowCore::Definition::Place
          tag_or_place
        else
          attributes[:name] ||= tag_or_place.to_s
          FlowCore::Definition::Place.new(tag_or_place, attributes)
        end

      @places << entity unless @places.include?(entity)
      entity
    end

    def start_place(tag, attributes = {})
      raise "`start_place` can only call once" if @start_tag

      place = FlowCore::Definition::Place.new(tag, attributes.merge(type: FlowCore::StartPlace.to_s))
      @places << place
      @start_tag = place.tag
      place
    end

    def end_place(tag, attributes = {})
      raise "`end_place` can only call once" if @end_tag

      place = FlowCore::Definition::Place.new(tag, attributes.merge(type: FlowCore::EndPlace.to_s))
      @places << place
      @end_tag = place.tag
      place
    end

    def transition(tag, options = {}, &block)
      raise TypeError unless tag.is_a? Symbol
      raise ArgumentError if @transitions.include? tag

      @transitions << FlowCore::Definition::Transition.new(self, tag, options, &block)
    end

    def compile
      {
        attributes: @attributes,
        start_tag: @start_tag,
        end_tag: @end_tag,
        places: @places.map(&:compile),
        transitions: @transitions.map(&:compile)
      }
    end

    def deploy!
      # TODO: Simple validation

      workflow = nil
      FlowCore::ApplicationRecord.transaction do
        workflow = FlowCore::Workflow.new attributes
        workflow.save!

        # Places
        place_records = {}
        places.each do |pd|
          place_records[pd.tag] =
            workflow.places.create! pd.attributes
        end

        # Transitions
        transition_records = {}
        transitions.each do |td|
          transition_records[td.tag] =
            workflow.transitions.create! td.attributes

          if td.trigger
            transition_records[td.tag].create_trigger! td.trigger.compile
          end

          td.callbacks.each do |cb|
            transition_records[td.tag].callbacks.create! cb.compile
          end

          td.input_tags.each do |place_tag|
            workflow.arcs.in.create! transition: transition_records[td.tag],
                                     place: place_records[place_tag]
          end

          td.output_tags.each do |output|
            arc = workflow.arcs.out.create! transition: transition_records[td.tag],
                                            place: place_records[output[:tag]],
                                            fallback_arc: output[:fallback]
            output[:guards].each do |guard|
              arc.guards.create! guard.compile
            end
          end
        end
      end
      workflow&.verify!
      workflow
    end
  end
end
