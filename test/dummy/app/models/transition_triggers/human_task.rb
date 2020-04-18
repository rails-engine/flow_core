# frozen_string_literal: true

module TransitionTriggers
  class HumanTask < FlowCore::TransitionTrigger
    serialize :configuration, Configuration

    def configurable?
      true
    end

    def on_task_enable(task)
      transaction do
        assignee =
          case configuration.assign_to
          when Configuration::ASSIGN_TO_ENUM[:user]
            User.find(configuration.assignee_user_id)
          when Configuration::ASSIGN_TO_ENUM[:instance_creator]
            task.instance.creator
          else
            raise "Invalid `assign_to` value - #{configuration.assign_to}"
          end
        t = task_class.create!(
          task: task, workflow_tag: task.workflow.tag, transition_tag: task.transition.tag, assignee: assignee
        )
        task.update! executable: t
      end
    end

    private

      def task_class
        ::HumanTask
      end
  end
end
