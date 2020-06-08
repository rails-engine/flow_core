# frozen_string_literal: true

module FlowKit::TransitionTriggers
  class HumanTask < FlowCore::TransitionTrigger
    belongs_to :attached_form, class_name: "FormKit::Form", optional: true

    has_many :assignee_candidates, foreign_key: :trigger_id, inverse_of: :trigger, dependent: :delete_all
    has_many :assignee_candidate_users, through: :assignee_candidates, source: :assignable, source_type: "User"

    serialize :configuration, Configuration

    validates :assignee_candidates,
              length: { minimum: 1 },
              if: ->(r) { r.configuration.assign_to_candidate? }

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

        human_task = task_class.new task: task, attached_form: attached_form
        if assignee
          human_task.assignable = assignee
          human_task.status = :assigned
          human_task.assigned_at = Time.zone.now
        else
          human_task.status = :unassigned
        end
        human_task.save!
        task.update! executable: human_task
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
