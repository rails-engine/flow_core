# frozen_string_literal: true

module FlowKit::ArcGuards
  class RubyScript
    class Configuration < SerializableModel::Base
      attribute :name, :string
      attribute :script, :string

      validates :name, :script,
                presence: true
    end
  end
end
