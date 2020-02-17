# frozen_string_literal: true

module FlowCore
  class Token < FlowCore::ApplicationRecord
    self.table_name = "flow_core_tokens"

    belongs_to :workflow, class_name: "FlowCore::Workflow"
    belongs_to :instance, class_name: "FlowCore::Instance"
    belongs_to :place, class_name: "FlowCore::Place"

    belongs_to :created_by_task, class_name: "FlowCore::Task", optional: true
    belongs_to :consumed_by_task, class_name: "FlowCore::Task", optional: true

    enum stage: {
      free: 0,
      locked: 1,
      consumed: 11,
      terminated: 12
    }

    after_create :auto_create_task
    after_create :auto_enable_task
    after_create :auto_finish_instance, if: ->(token) { token.place.is_a? EndPlace }

    before_validation do
      self.workflow ||= instance&.workflow
    end

    def can_lock?
      free?
    end

    def can_consume?
      locked?
    end

    def can_terminate?
      free? || locked?
    end

    def lock
      return false unless can_lock?

      update! stage: :locked, locked_at: Time.zone.now

      true
    end

    def consume(by:)
      return false unless can_consume?

      update! stage: :consumed,
              consumed_by_task: by,
              consumed_at: Time.zone.now

      true
    end

    def terminate
      return false unless can_terminate?

      update! stage: :terminated,
              terminated_at: Time.zone.now

      true
    end

    def lock!
      lock || raise(FlowCore::InvalidTransition, "Can't lock Task##{id}")
    end

    def consume!(by:)
      consume(by: by) || raise(FlowCore::InvalidTransition, "Can't consume Task##{id}")
    end

    def terminate!
      terminate || raise(FlowCore::InvalidTransition, "Can't terminate Task##{id}")
    end

    def create_task!
      return if task_created

      transaction do
        place.output_transitions.each do |transition|
          transition.create_task_if_needed(token: self)
        end
        update! task_created: true
      end
    end

    private

      def auto_create_task
        create_task!
      end

      def auto_enable_task
        instance.tasks.created.where(transition: place.output_transitions).find_each(&:enable)
      end

      def auto_finish_instance
        instance.finish!
      end
  end
end
