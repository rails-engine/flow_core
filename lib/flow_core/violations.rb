# frozen_string_literal: true

require "active_support/core_ext/array/conversions"
require "active_support/core_ext/string/inflections"
require "active_support/core_ext/object/deep_dup"
require "active_support/core_ext/string/filters"

module FlowCore
  class Violations
    include Enumerable

    MESSAGE_OPTIONS = %i[message].freeze

    attr_reader :messages, :details, :records

    def initialize
      @messages = apply_default_array({})
      @details = apply_default_array({})
      @records = apply_default_array({})
    end

    def initialize_dup(other) # :nodoc:
      @messages = other.messages.dup
      @details  = other.details.deep_dup
      @records = other.records.deep_dup
      super
    end

    def copy!(other) # :nodoc:
      @messages = other.messages.dup
      @details  = other.details.dup
      @records  = other.records.dup
    end

    def merge!(other)
      @messages.merge!(other.messages) { |_, ary1, ary2| ary1 + ary2 }
      @details.merge!(other.details) { |_, ary1, ary2| ary1 + ary2 }
      @records.merge!(other.records) { |_, ary1, ary2| ary1 + ary2 }
    end

    def slice!(*keys)
      keys = keys.map(&:to_sym)
      @details.slice!(*keys)
      @messages.slice!(*keys)
      @records.slice!(*keys)
    end

    def clear
      messages.clear
      details.clear
      records.clear
    end

    def include?(record)
      record = "#{record.class}/#{record.id}"
      messages.key?(record) && messages[record].present?
    end
    alias has_key? include?
    alias key? include?

    def delete(record)
      record = "#{record.class}/#{record.id}"
      details.delete(record)
      messages.delete(record)
      records.delete(record)
    end

    def [](record)
      record = "#{record.class}/#{record.id}"
      messages[record]
    end

    def each
      messages.each_key do |record_key|
        model = records[record_key][:model]
        id = records[record_key][:id]
        name = records[record_key][:name]
        messages[record_key].each { |error| yield record_key, model, id, name, error }
      end
    end

    def size
      values.flatten.size
    end
    alias count size

    def values
      messages.reject do |_key, value|
        value.empty?
      end.values
    end

    def keys
      messages.reject do |_key, value|
        value.empty?
      end.keys
    end

    def empty?
      size.zero?
    end
    alias blank? empty?

    def to_xml(options = {})
      to_a.to_xml({ root: "errors", skip_types: true }.merge!(options))
    end

    def as_json(options = nil)
      to_hash(options && options[:full_messages])
    end

    def to_hash(full_messages = false)
      if full_messages
        messages.each_with_object({}) do |(record_key, array), messages|
          messages[record_key] = array.map { |message| full_message(record_key, message) }
        end
      else
        without_default_proc(messages)
      end
    end

    def add(record, message = :invalid, options = {})
      message = message.call if message.respond_to?(:call)
      detail  = normalize_detail(message, options)
      message = normalize_message(record, message, options)
      n_record = normalize_record(record)

      record_key = "#{record.class}/#{record.id}"
      details[record_key] << detail
      messages[record_key] << message
      records[record_key] = n_record

      if exception = options[:strict]
        exception = FlowCore::StrictViolationFailed if exception == true
        raise exception, full_message(record_key, message)
      end
    end

    def added?(record, message = :invalid, options = {})
      message = message.call if message.respond_to?(:call)

      record_key = "#{record.class}/#{record.id}"
      if message.is_a? Symbol
        details[record_key].include? normalize_detail(message, options)
      else
        self[record_key].include? message
      end
    end

    def of_kind?(record, message = :invalid)
      message = message.call if message.respond_to?(:call)

      record_key = "#{record.class}/#{record.id}"
      if message.is_a? Symbol
        details[record_key].map { |e| e[:error] }.include? message
      else
        self[record_key].include? message
      end
    end

    def full_messages
      map do |record_key, _, _, _, message|
        full_message(record_key, message)
      end
    end
    alias to_a full_messages

    def full_messages_for(record)
      record_key = "#{record.class}/#{record.id}"
      messages[record].map { |message| full_message(record_key, message) }
    end

    def full_message(record_key, message)
      model = records[record_key][:model]
      model_name = records[record_key][:model].model_name.human
      id = records[record_key][:id]
      name = records[record_key][:name]

      defaults = [:"flow_core.violations.format"]
      defaults << "%<name>s %<message>s"

      I18n.t(defaults.shift,
             default: defaults, model: model, model_name: model_name, id: id, name: name, message: message)
    end

    def generate_message(record, type = :invalid, options = {})
      type = options.delete(:message) if options[:message].is_a?(Symbol)

      options = {
        model: record.class,
        model_name: record.model_name.human,
        id: record.id,
        name: record.name
      }.merge!(options)

      options[:default] = options.delete(:message) if options[:message]

      I18n.translate("flow_core.violations.#{type}", options)
    end

    def marshal_dump # :nodoc:
      [without_default_proc(@messages), without_default_proc(@details), without_default_proc(@records)]
    end

    def marshal_load(array) # :nodoc:
      @messages, @details, @records = array
      apply_default_array(@messages)
      apply_default_array(@details)
      apply_default_array(@records)
    end

    def init_with(coder) # :nodoc:
      coder.map.each { |k, v| instance_variable_set(:"@#{k}", v) }
      @details ||= {}
      apply_default_array(@messages)
      apply_default_array(@details)
      apply_default_array(@records)
    end

    private

      def normalize_message(record, message, options)
        case message
        when Symbol
          generate_message(record, message, options)
        else
          message
        end
      end

      def normalize_detail(message, options)
        { error: message }.merge(options.except(*MESSAGE_OPTIONS))
      end

      def normalize_record(record)
        { model: record.class, id: record.id, name: record.name }
      end

      def without_default_proc(hash)
        hash.dup.tap do |new_h|
          new_h.default_proc = nil
        end
      end

      def apply_default_array(hash)
        hash.default_proc = proc { |h, key| h[key] = [] }
        hash
      end
  end

  class StrictViolationFailed < StandardError
  end
end
