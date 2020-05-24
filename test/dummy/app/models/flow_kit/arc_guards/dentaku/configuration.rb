# frozen_string_literal: true

module FlowKit::ArcGuards
  class Dentaku
    class Configuration < SerializableModel::Base
      attribute :name, :string
      attribute :expression, :string

      validates :name, :expression,
                presence: true
    end
  end
end
