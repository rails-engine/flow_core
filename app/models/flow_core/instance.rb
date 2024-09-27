# frozen_string_literal: true

module FlowCore
  class Instance < FlowCore::ApplicationRecord
    self.table_name = "flow_core_instances"

    FORBIDDEN_ATTRIBUTES = %i[
      workflow_id stage activated_at finished_at canceled_at terminated_at terminate_reason
      created_at updated_at
    ].freeze

    belongs_to :workflow, class_name: "FlowCore::Workflow"

    has_many :tokens, class_name: "FlowCore::Token", dependent: :delete_all
    has_many :tasks, class_name: "FlowCore::Task", dependent: :delete_all

    serialize :payload, coder: YAML

    enum stage: {
      created: 0,
      activated: 1,
      canceled: 2,
      finished: 11,
      terminated: 12
    }

    scope :errored, -> { where.not(errored_at: nil) }
    scope :suspended, -> { where.not(suspended_at: nil) }

    after_initialize do
      self.payload ||= {}
    end

    include FlowCore::TaskCallbacks

    def errored?
      tasks.where.not(errored_at: nil).exists?
    end

    def can_cancel?
      created?
    end

    def can_activate?
      created?
    end

    def can_finish?
      activated?
    end

    def can_terminate?
      true
    end

    def cancel
      return false unless can_cancel?

      with_transaction_returning_status do
        update! stage: :canceled, canceled_at: Time.zone.now

        true
      end
    end

    def activate
      return false unless can_activate?

      with_transaction_returning_status do
        update! stage: :activated, activated_at: Time.zone.now

        tokens.create! place: workflow.start_place

        true
      end
    end

    def finish
      return false unless can_finish?

      with_transaction_returning_status do
        update! stage: :finished, finished_at: Time.zone.now

        tasks.where(stage: %i[created enabled]).find_each do |task|
          task.terminate! reason: "Instance finished"
        end
        tokens.where(stage: %i[free locked]).find_each(&:terminate!)

        true
      end
    end

    def terminate(reason:)
      return unless can_terminate?

      with_transaction_returning_status do
        tasks.enabled.each { |task| task.terminate! reason: "Instance terminated" }
        update! stage: :terminated, terminated_at: Time.zone.now, terminate_reason: reason

        true
      end
    end

    def cancel!
      cancel || raise(FlowCore::InvalidTransition, "Can't cancel Instance##{id}")
    end

    def activate!
      activate || raise(FlowCore::InvalidTransition, "Can't activate Instance##{id}")
    end

    def finish!
      finish || raise(FlowCore::InvalidTransition, "Can't finish Instance##{id}")
    end

    def terminate!(reason:)
      terminate(reason: reason) || raise(FlowCore::InvalidTransition, "Can't terminate Instance##{id}")
    end
  end
end
