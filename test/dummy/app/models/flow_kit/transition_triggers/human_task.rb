# frozen_string_literal: true

module FlowKit::TransitionTriggers
  class HumanTask < FlowCore::TransitionTrigger
    belongs_to :attached_form, class_name: "FormKit::Form", optional: true
    belongs_to :form_override, class_name: "FormKit::FormOverride", optional: true

    has_many :assignee_candidates, foreign_key: :trigger_id, inverse_of: :trigger, dependent: :delete_all
    has_many :assignee_candidate_users, through: :assignee_candidates, source: :assignable, source_type: "User"

    serialize :configuration, coder: Configuration

    validates :assignee_candidates,
              length: { minimum: 1 },
              if: ->(r) { r.configuration.assign_to_candidate? }

    delegate :form, to: :workflow, allow_nil: false

    def configurable?
      true
    end

    def on_task_enable(task)
      transaction do
        assignee =
          case configuration.assign_to
          when Configuration::ASSIGN_TO_ENUM[:candidate]
            assignee_candidates.order("random()").first&.assignable
          when Configuration::ASSIGN_TO_ENUM[:instance_creator]
            task.instance&.creator
          else
            raise "Invalid `assign_to` value - #{configuration.assign_to}"
          end

        human_task = task_class.create! task: task, attached_form: attached_form, form_override: form_override, status: :unassigned
        human_task.assign! assignee
      end
    end

    def dup
      obj = super
      obj.assignee_candidate_user_ids = assignee_candidate_user_ids
      obj
    end

    private

      def task_class
        FlowKit::HumanTask
      end
  end
end
