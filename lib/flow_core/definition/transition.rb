# frozen_string_literal: true

module FlowCore::Definition
  class Transition
    attr_reader :net, :tag, :attributes, :trigger, :input_tags, :output_tags

    private :net

    def initialize(net, tag, attributes = {}, &block)
      raise TypeError unless net.is_a? FlowCore::Definition::Net
      raise TypeError unless tag.is_a? Symbol

      @net = net
      @tag = tag
      @input_tags = []
      @output_tags = []

      input = attributes.delete(:input)
      output = attributes.delete(:output)
      raise ArgumentError, "Require `input`" unless input

      inputs(*input)
      outputs(*output) if output

      trigger = attributes.delete :with_trigger
      @trigger =
        if trigger
          FlowCore::Definition::Trigger.new trigger
        end

      @attributes = attributes.with_indifferent_access.except(FlowCore::Transition::FORBIDDEN_ATTRIBUTES)
      @attributes[:name] ||= tag.to_s
      @attributes[:tag] ||= tag.to_s

      block&.call(self)
    end

    def with_trigger(type, attributes = {})
      @trigger = FlowCore::Definition::Trigger.new attributes.merge(type: type)
    end

    def input(tag, attributes = {})
      unless net.places.find { |place| place.tag == tag }
        net.add_place(tag, attributes)
      end

      @input_tags << tag
    end

    def inputs(*tags)
      tags.each do |tag|
        case tag
        when Symbol
          input(tag)
        when Array # Expect `[:p1, {name: "Place 1"}]`
          input(*tag)
        else
          raise TypeError, "Unknown pattern - #{place}"
        end
      end
    end

    def output(tag, attributes = {})
      guards = []
      guards.concat Array.wrap(attributes.delete(:with_guards))
      guards.concat Array.wrap(attributes.delete(:with_guard))
      guards.compact!
      guards.map! { |guard| FlowCore::Definition::Guard.new guard }

      fallback = attributes.delete(:fallback) || false

      unless net.places.find { |place| place.tag == tag }
        net.add_place(tag, attributes)
      end

      @output_tags << { tag: tag, guards: guards, fallback: fallback }
    end

    def outputs(*tags)
      tags.each do |tag|
        case tag
        when Symbol
          output(tag)
        when Array # Expect `[:p1, {name: "Place 1"}]`
          output(*tag)
        else
          raise TypeError, "Unknown pattern - #{place}"
        end
      end
    end

    def compile
      {
        tag: @tag,
        attributes: @attributes,
        trigger: @trigger&.compile,
        input_tags: @input_tags,
        output_tags: @output_tags.map { |output| { tag: output[:tag], guards: output[:guards].map(&:compile) } }
      }
    end
  end
end
