# frozen_string_literal: true

module FlowCore
  class Instance < FlowCore::ApplicationRecord
    self.table_name = "flow_core_instances"

    FORBIDDEN_ATTRIBUTES = %i[
      workflow_id stage activated_at finished_at canceled_at terminated_at terminated_reason
      errored_at rescued_at suspended_at resumed_at created_at updated_at
    ].freeze

    belongs_to :workflow, class_name: "FlowCore::Workflow"

    has_many :tokens, class_name: "FlowCore::Token", dependent: :delete_all
    has_many :tasks, class_name: "FlowCore::Task", dependent: :delete_all

    serialize :payload

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

    def errored?
      errored_at.present?
    end

    def suspended?
      suspended_at.present?
    end

    def can_active?
      created?
    end

    def can_finish?
      activated?
    end

    def active
      return false unless can_active?

      transaction do
        tokens.create! place: workflow.start_place
        update! stage: :activated, activated_at: Time.zone.now
      end

      true
    end

    def finish
      return false unless can_finish?

      transaction do
        update! stage: :finished, finished_at: Time.zone.now

        tasks.where(stage: %i[created enabled]).find_each do |task|
          task.terminate! reason: "Instance finished"
        end
        tokens.where(stage: %i[free locked]).find_each(&:terminate!)
      end

      true
    end

    def active!
      active || raise(FlowCore::InvalidTransition, "Can't active Instance##{id}")
    end

    def finish!
      finish || raise(FlowCore::InvalidTransition, "Can't finish Instance##{id}")
    end

    def error!
      return if errored?

      update! errored_at: Time.zone.now
    end

    def rescue!
      return unless errored?
      return unless tasks.errored.any?

      update! errored_at: nil, rescued_at: Time.zone.now
    end

    def suspend!
      return if suspended?

      transaction do
        tasks.enabled.each(&:suspend!)
        update! suspended_at: Time.zone.now
      end
    end

    def resume!
      return unless suspended?

      transaction do
        tasks.enabled.each(&:resume!)
        update! suspended_at: nil, resumed_at: Time.zone.now
      end
    end
  end
end
