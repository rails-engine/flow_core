# frozen_string_literal: true

module FlowCore::Definition
  class Transition
    attr_reader :net, :tag, :attributes, :trigger, :callbacks, :input_tags, :output_tags
    private :net

    def initialize(net, tag, attributes = {}, &block)
      raise TypeError unless net.is_a? FlowCore::Definition::Net
      raise TypeError unless tag.is_a? Symbol

      @net = net
      @tag = tag
      @input_tags = []
      @output_tags = []
      @callbacks = []

      input = attributes.delete(:input)
      output = attributes.delete(:output)
      raise ArgumentError, "Require `input`" unless input

      self.input input
      self.output output if output

      trigger = attributes.delete :with_trigger
      @trigger =
        if trigger
          FlowCore::Definition::Trigger.new trigger
        end

      callbacks = []
      callbacks.concat Array.wrap(attributes.delete(:with_callbacks))
      callbacks.concat Array.wrap(attributes.delete(:with_callback))
      @callbacks = callbacks.map { |cb| FlowCore::Definition::Callback.new cb }

      @attributes = attributes.with_indifferent_access.except(FlowCore::Transition::FORBIDDEN_ATTRIBUTES)
      @attributes[:name] ||= tag.to_s
      @attributes[:tag] ||= tag.to_s

      block&.call(self)
    end

    def with_trigger(type, attributes = {})
      @trigger = FlowCore::Definition::Trigger.new attributes.merge(type: type)
    end

    def with_callback(type, attributes = {})
      @callbacks << FlowCore::Definition::Callback.new(attributes.merge(type: type))
    end

    def with_callbacks(*callbacks)
      callbacks.each do |cb|
        with_callback(*cb)
      end
    end

    def input(tag)
      places = Array.wrap(tag)
      places.each do |place|
        case place
        when Symbol
          net.add_place(place)
          tag = place
        when Array # Expect `[:p1, {name: "Place 1"}]`
          net.add_place(*place)
          tag = place.first
        else
          raise TypeError, "Unknown pattern - #{place}"
        end

        @input_tags << tag
      end
    end

    def output(tag, attributes = {})
      guard = attributes.delete :with_guard
      guard = FlowCore::Definition::Guard.new(guard) if guard&.is_a?(Hash)

      places = Array.wrap(tag)
      places.each do |place|
        case place
        when Symbol
          net.add_place(place)
          tag = place
        when Array # Expect `[:p1, {name: "Place 1"}]`
          net.add_place(*place)
          tag = place.first
        else
          raise TypeError, "Unknown pattern - #{place}"
        end

        @output_tags << { tag: tag, guard: guard }
      end
    end

    def compile
      {
        tag: @tag,
        attributes: @attributes,
        trigger: @trigger&.compile,
        callbacks: @callbacks.map(&:compile),
        input_tags: @input_tags,
        output_tags: @output_tags.map { |output| { tag: output[:tag], guard: output[:guard]&.compile } }
      }
    end
  end
end
