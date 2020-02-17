# frozen_string_literal: true

module FlowCore::Definition
  class Place
    attr_reader :tag, :attributes

    def initialize(tag, attributes = {})
      raise TypeError unless tag.is_a? Symbol

      @tag = tag
      @attributes = attributes.with_indifferent_access.except(FlowCore::Place::FORBIDDEN_ATTRIBUTES)
      @attributes[:name] ||= tag.to_s
      @attributes[:tag] ||= tag.to_s
    end

    def compile
      {
        tag: @tag,
        attributes: @attributes
      }
    end

    def eql?(other)
      if other.is_a? FlowCore::Definition::Place
        @tag == other.tag
      else
        false
      end
    end

    alias == eql?
  end
end
