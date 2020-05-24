# frozen_string_literal: true

module FlowCore::Steps
  class Redirection < FlowCore::Step
    def deploy_to_workflow!(workflow, input_place_or_transition)
      input_place = find_or_create_input_place(workflow, input_place_or_transition)
      target_transition = workflow.transitions.find_by! generated_by_step_id: redirect_to_step_id

      input_place.output_transitions << target_transition

      nil
    end

    class << self
      def creatable?
        true
      end

      def redirection_step?
        true
      end

      def redirection_configurable?
        true
      end
    end

    private

      def update_verified
        self.verified = errors.empty? && redirect_to_step_id.present?
      end
  end
end
