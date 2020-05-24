# frozen_string_literal: true

module FlowKit::TransitionTriggerConfiguration
  module Assignable
    extend ActiveSupport::Concern

    included do
      attribute :assignee_user_id, :integer
      attribute :assign_to, :string, default: "user"

      enum assign_to: {
        instance_creator: "instance_creator",
        user: "user"
      }, _prefix: :assign_to

      validates :assign_to,
                presence: true
      validates :assignee_user_id,
                presence: true,
                if: ->(record) { record.assign_to_user? }
    end
  end
end
