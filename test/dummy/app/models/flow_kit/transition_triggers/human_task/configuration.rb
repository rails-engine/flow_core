# frozen_string_literal: true

module FlowKit::TransitionTriggers
  class HumanTask
    class Configuration < SerializableModel::Base
      ASSIGN_TO_ENUM = {
        instance_creator: "instance_creator",
        candidate: "candidate"
      }.freeze

      attribute :assign_to, :string, default: ASSIGN_TO_ENUM[:instance_creator]
      enum assign_to: ASSIGN_TO_ENUM,
           _prefix: :assign_to

      validates :assign_to,
                presence: true
    end
  end
end
