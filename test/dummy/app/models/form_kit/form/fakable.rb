# frozen_string_literal: true

class FormKit::Form
  module Fakable
    extend ActiveSupport::Concern

    def build_random_fields(type_key_seq:)
      transaction do
        type_key_seq.each do |type_key|
          if type_key.is_a? Hash
            type_key.each do |k, v|
              klass = FormKit::Fields::MAP[k]
              unless k.attached_nested_form?
                raise ArgumentError, "Only nested form types can be key"
              end

              field = fields.build type: FormKit::Fields::MAP[type_key].to_s
              field.name = "#{klass.model_name.name.demodulize.titleize} #{field.name.to_s.split('_').last}"
              field.save!
              klass.configure_fake_options_to field
              field.save!
              field.nested_form.build_random_fields(v)
              field.save!
            end
          else
            klass = FormKit::Fields::MAP[type_key]
            unless klass
              raise ArgumentError, "Can't reflect field class by #{type_key}"
            end

            field = fields.build type: FormKit::Fields::MAP[type_key].to_s
            field.name = "#{klass.model_name.name.demodulize.titleize} #{field.name.to_s.split('_').last}"
            field.save!
            klass.configure_fake_options_to field
            field.save!
          end
        end
      end
    end

    module ClassMethods
      DEFAULT_TYPE_KEY_SEQ =
        FormKit::Fields.all_types.map(&:type_key) -
        %i[nested_form multiple_nested_form] -
        %i[attachment multiple_attachment] -
        %i[resource_select multiple_resource_select] -
        %i[resource multiple_resource]
      def create_random_form!(type_key_seq: DEFAULT_TYPE_KEY_SEQ)
        form = FormKit::Form.create! name: "Random form #{SecureRandom.hex(3)}"
        form.build_random_fields type_key_seq: type_key_seq
        form
      end
    end
  end
end
