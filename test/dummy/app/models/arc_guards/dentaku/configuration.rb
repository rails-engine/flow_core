# frozen_string_literal: true

module ArcGuards
  class Dentaku
    class Configuration < SerializableConfiguration
      attribute :name, :string
      attribute :expression, :string

      validates :name, :expression,
                presence: true
    end
  end
end
