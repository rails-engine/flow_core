# frozen_string_literal: true

module FormKit
  class VirtualModel < FormCore::VirtualModel
    include SerializableModel::ActsAsDefaultValue
    include SerializableModel::EnumAttributeLocalizable

    def persisted?
      false
    end

    def dump
      self.class.dump(self)
    end

    class << self
      def reserved_attribute_names
        @reserved_attribute_names ||= Set.new(
          %i[def class module private public protected allocate new parent superclass] +
            instance_methods(true)
        )
      end

      def nested_models
        @nested_models ||= {}
      end

      def attr_readonly?(attr_name)
        readonly_attributes.include? attr_name.to_s
      end

      def metadata
        @metadata ||= {}
      end
    end
  end
end
