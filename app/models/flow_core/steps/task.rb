# frozen_string_literal: true

module FlowCore::Steps
  class Task < FlowCore::Step
    def deploy_to_workflow!(workflow, input_place_or_transition)
      input_place = find_or_create_input_place(workflow, input_place_or_transition)

      transition = input_place.output_transitions.create! workflow: workflow, name: name, generated_by_step_id: id
      copy_transition_trigger_to transition

      transition
    end

    class << self
      def creatable?
        true
      end

      def transition_trigger_required?
        true
      end
    end
  end
end
