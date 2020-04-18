# frozen_string_literal: true

module TransitionTriggers
  class HumanTask
    class Configuration < SerializableConfiguration
      ASSIGN_TO_ENUM = {
        instance_creator: "instance_creator",
        user: "user"
      }.freeze

      attribute :assignee_user_id, :integer
      attribute :assign_to, :string, default: ASSIGN_TO_ENUM[:instance_creator]

      validates :assign_to,
                presence: true
      validates :assignee_user_id,
                presence: true,
                if: ->(record) { record.assign_to == ASSIGN_TO_ENUM[:user] }
    end
  end
end
