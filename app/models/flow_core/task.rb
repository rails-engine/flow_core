# frozen_string_literal: true

module FlowCore
  class Task < FlowCore::ApplicationRecord
    self.table_name = "flow_core_tasks"

    belongs_to :workflow, class_name: "FlowCore::Workflow"
    belongs_to :transition, class_name: "FlowCore::Transition"

    belongs_to :instance, class_name: "FlowCore::Instance", autosave: true
    belongs_to :created_by_token, class_name: "FlowCore::Token", optional: true

    belongs_to :executable, polymorphic: true, optional: true

    serialize :payload

    delegate :payload, to: :instance, prefix: :instance, allow_nil: false

    enum stage: {
      created: 0,
      enabled: 1,
      finished: 11,
      terminated: 12
    }

    scope :errored, -> { where.not(errored_at: nil) }
    scope :suspended, -> { where.not(suspended_at: nil) }

    after_initialize do
      self.payload ||= {}
    end

    before_validation do
      self.workflow ||= instance&.workflow
    end

    validate do
      next unless executable

      unless executable.is_a? FlowCore::TaskExecutable
        errors.add :executable, :invalid
      end
    end

    def errored?
      errored_at.present?
    end

    def suspended?
      suspended_at.present?
    end

    def can_enable?
      return false unless created?

      if input_free_tokens.size == transition.input_arcs.size
        return true
      end

      # Note: It's impossible of it create by a token and needs another token (AND join) to enable?
      same_origin_tasks.enabled.any?
    end

    def can_finish?
      return false unless enabled?

      return false if errored? || suspended?

      if executable
        executable.finished?
      else
        true
      end
    end

    def can_terminate?
      created? || enabled?
    end

    def enable
      return false unless can_enable?

      status =
        with_transaction_returning_status do
          input_free_tokens.each(&:lock!)
          update! stage: :enabled, enabled_at: Time.zone.now

          transition.on_task_enable(self)
          instance.on_task_enable(self)

          true
        end

      try_auto_finish if status

      status
    end

    def finish
      return false unless can_finish?

      with_transaction_returning_status do
        # terminate other racing tasks
        instance.tasks.enabled.where(created_by_token: created_by_token).find_each do |task|
          task.terminate! reason: "Same origin task #{id} finished"
        end

        input_locked_tokens.each { |token| token.consume! by: self }
        update! stage: :finished, finished_at: Time.zone.now

        transition.on_task_finish(self)
        instance.on_task_finish(self)

        true
      end

      create_output_token
    end

    def terminate(reason:)
      return false unless can_terminate?

      with_transaction_returning_status do
        update! stage: :terminated, terminated_at: Time.zone.now, terminate_reason: reason

        executable&.on_flow_core_task_terminate(self)
        transition.on_task_terminate(self)
        instance.on_task_terminate(self)

        true
      end
    end

    def error(error)
      update! errored_at: Time.zone.now, error_reason: error.message
      instance.update! errored_at: Time.zone.now

      transition.on_task_errored(self, error)
      instance.on_task_errored(self, error)

      true
    end

    def rescue
      return unless errored?

      with_transaction_returning_status do
        update! errored_at: nil, rescued_at: Time.zone.now
        instance.update! errored_at: nil, rescued_at: Time.zone.now

        transition.on_task_rescue(self)
        instance.on_task_rescue(self)

        true
      end
    end

    def suspend
      with_transaction_returning_status do
        update! suspended_at: Time.zone.now

        executable&.on_flow_core_task_suspend(self)
        transition.on_task_suspend(self)
        instance.on_task_suspend(self)

        true
      end
    end

    def resume
      with_transaction_returning_status do
        update! suspended_at: nil, resumed_at: Time.zone.now

        executable&.on_flow_core_task_resume(self)
        transition.on_task_resume(self)
        instance.on_task_resume(self)

        true
      end
    end

    def create_output_token
      return if output_token_created

      with_transaction_returning_status do
        transition.create_output_tokens_for(self)
        update! output_token_created: true

        true
      end
    end

    def enable!
      enable || raise(FlowCore::InvalidTransition, "Can't enable Task##{id}")
    end

    def finish!
      finish || raise(FlowCore::InvalidTransition, "Can't finish Task##{id}")
    end

    def terminate!(reason:)
      terminate(reason: reason) || raise(FlowCore::InvalidTransition, "Can't terminate Task##{id}")
    end

    alias error! error

    def rescue!
      self.rescue || raise(FlowCore::InvalidTransition, "Can't rescue Task##{id}")
    end

    def suspend!
      suspend || raise(FlowCore::InvalidTransition, "Can't suspend Task##{id}")
    end

    def resume!
      resume || raise(FlowCore::InvalidTransition, "Can't resume Task##{id}")
    end

    private

      def input_tokens
        instance.tokens.where(place: transition.input_places)
      end

      def input_free_tokens
        input_tokens.free.uniq(&:place_id)
      end

      def input_locked_tokens
        input_tokens.locked.uniq(&:place_id)
      end

      def same_origin_tasks
        instance.tasks.where(created_by_token: created_by_token)
      end

      def try_auto_finish
        return unless can_finish?

        if transition.auto_finish_strategy == "synchronously"
          finish
        end
      end
  end
end
