# frozen_string_literal: true

module FlowCore
  class Transition < FlowCore::ApplicationRecord
    self.table_name = "flow_core_transitions"

    FORBIDDEN_ATTRIBUTES = %i[workflow_id created_at updated_at].freeze

    belongs_to :workflow, class_name: "FlowCore::Workflow"

    # NOTE: Place - out -> Transition - in -> Place
    has_many :input_arcs, -> { where(direction: :in) },
             class_name: "FlowCore::Arc", inverse_of: :transition, dependent: :delete_all
    has_many :output_arcs, -> { where(direction: :out) },
             class_name: "FlowCore::Arc", inverse_of: :transition, dependent: :delete_all

    has_many :input_places, through: :input_arcs, class_name: "FlowCore::Place", source: :place

    has_one :trigger, class_name: "FlowCore::TransitionTrigger", dependent: :delete
    has_many :callbacks, class_name: "FlowCore::TransitionCallback", dependent: :delete_all

    before_destroy :prevent_destroy
    after_create :reset_workflow_verification
    after_destroy :reset_workflow_verification

    def output_and_split?
      output_arcs.includes(:guards).all? { |arc| arc.guards.empty? }
    end

    def output_explicit_or_split?
      output_arcs.includes(:guards).select { |arc| arc.guards.any? } < output_arcs.size
    end

    def input_and_join?
      input_arcs.size > 1
    end

    def input_sequence?
      input_arcs.size == 1
    end

    def output_sequence?
      output_arcs.size == 1
    end

    def verify(violations:)
      trigger&.on_verify(self, violations)
    end

    def create_task_if_needed(token:)
      instance = token.instance
      candidate_tasks = instance.tasks.created.where(transition: self)

      # TODO: Is it possible that a input place has more than one free tokens? if YES we should handle it
      if candidate_tasks.empty?
        token.instance.tasks.create! transition: self, created_by_token: token
      end
    end

    def create_tokens_for_output(task:)
      instance = task.instance
      arcs = output_arcs.includes(:place, :guards).to_a

      end_arc = arcs.find { |arc| arc.place.is_a? EndPlace }
      if end_arc
        if end_arc.guards.empty? || end_arc.guards.map { |guard| guard.permit? task }.reduce(&:&)
          instance.tokens.create! created_by_task: task, place: end_arc.place
          return
        end

        arcs.delete(end_arc)
      end

      candidate_arcs = arcs.select do |arc|
        arc.guards.empty? || arc.guards.map { |guard| guard.permit? task }.reduce(&:&)
      end

      if candidate_arcs.empty?
        trigger&.on_error(task, FlowCore::NoNewTokenCreated.new)
      end

      candidate_arcs.each do |arc|
        instance.tokens.create! created_by_task: task, place: arc.place
      end
    end

    def on_task_created(task)
      trigger&.on_task_created(task)
      callbacks.each { |callback| callback.call task }
    end

    def on_task_enabled(task)
      trigger&.on_task_enabled(task)
      callbacks.each { |callback| callback.call task }
    end

    def on_task_finished(task)
      trigger&.on_task_finished(task)
      callbacks.each { |callback| callback.call task }
    end

    def on_task_terminated(task)
      trigger&.on_task_terminated(task)
      callbacks.each { |callback| callback.call task }
    end

    def on_task_errored(task, error)
      trigger&.on_task_errored(task, error)
      callbacks.each { |callback| callback.call task }
    end

    def on_task_rescued(task)
      trigger&.on_task_rescued(task)
      callbacks.each { |callback| callback.call task }
    end

    def on_task_suspended(task)
      trigger&.on_task_suspended(task)
      callbacks.each { |callback| callback.call task }
    end

    def on_task_resumed(task)
      trigger&.on_task_resumed(task)
      callbacks.each { |callback| callback.call task }
    end

    def can_destroy?
      workflow.instances.empty?
    end

    private

      def reset_workflow_verification
        workflow.reset_workflow_verification!
      end

      def prevent_destroy
        unless can_destroy?
          raise FlowCore::ForbiddenOperation, "Found exists instance, destroy transition will lead serious corruption"
        end
      end
  end
end
