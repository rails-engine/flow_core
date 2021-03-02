# frozen_string_literal: true

module FormKit
  class Field < ApplicationRecord
    self.table_name = "form_kit_fields"

    has_many :overrides, class_name: "FormKit::FieldOverride", foreign_key: "field_id", inverse_of: :field, dependent: :delete_all

    belongs_to :form, class_name: "FormKit::MetalForm", touch: true

    # Only use for specific fields
    has_many :choices, -> { order(position: :asc) },
             class_name: "FormKit::Choice", inverse_of: :field,
             dependent: :destroy, autosave: true
    has_one :nested_form,
            class_name: "FormKit::NestedForm", as: :attachable, dependent: :destroy

    enum accessibility: { read_and_write: 0, readonly: 1, hidden: 2 },
         _prefix: :access

    acts_as_list

    NAME_REGEX = /\A[a-z][a-z_0-9]*\z/.freeze
    validates :key,
              presence: true,
              uniqueness: { scope: :form },
              exclusion: { in: FormKit::VirtualModel.reserved_attribute_names },
              format: { with: NAME_REGEX }

    validates :name,
              presence: true
    validates :accessibility,
              presence: true
    validates :type,
              inclusion: {
                in: ->(_) { FormKit::Fields.all_types.map(&:to_s) }
              },
              allow_blank: false

    default_value_for :key,
                      ->(_) { "field_#{SecureRandom.hex(3)}" },
                      allow_nil: false
    default_value_for :accessibility,
                      :read_and_write,
                      allow_nil: false

    def self.type_key
      model_name.name.demodulize.underscore.to_sym
    end

    def type_key
      self.class.type_key
    end

    def array?
      false
    end

    def stored_type
      raise NotImplementedError
    end

    def default_value
      nil
    end

    include Helper
    include Fakable

    def interpret_to(model, overrides: {})
      check_model_validity!(model)

      accessibility = overrides.fetch(:accessibility, self.accessibility).to_sym
      return model if accessibility == :hidden

      interpret_attribute_to model, accessibility, overrides
      interpret_validations_to model, accessibility, overrides
      interpret_options_to model, accessibility, overrides
      interpret_extra_to model, accessibility, overrides

      model
    end

    protected

      def interpret_attribute_to(model, accessibility, overrides = {})
        default_value = overrides.fetch(:default_value, self.default_value)
        if array?
          model.attribute key, stored_type, default: (default_value || []), array_without_blank: true
        else
          model.attribute key, stored_type, default: default_value
        end

        if accessibility == :readonly
          model.attr_readonly key
        end
      end

      def interpret_validations_to(model, accessibility, overrides = {})
        return unless accessibility == :read_and_write

        validations_overrides = overrides[:validations] || {}
        validations =
          if validations_overrides.any?
            self.validations.dup.update(validations_overrides)
          else
            self.validations
          end

        validations.interpret_to(model, key, accessibility)
      end

      def interpret_options_to(model, accessibility, overrides = {})
        options_overrides = overrides[:options] || {}
        options =
          if options_overrides.any?
            self.options.dup.update(options_overrides)
          else
            self.options
          end

        options.interpret_to(model, key, accessibility)
      end

      def interpret_extra_to(model, accessibility, overrides = {}); end

      def check_model_validity!(model)
        unless model.is_a?(Class) && model < ::FormKit::VirtualModel
          raise ArgumentError, "#{model} must be a #{::FormKit::VirtualModel}'s subclass"
        end
      end
  end
end
