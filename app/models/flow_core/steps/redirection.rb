# frozen_string_literal: true

module FlowCore::Steps
  class Redirection < FlowCore::Step
    def deploy_to_workflow!(workflow, input_place_or_transition)
      target_transition = workflow.transitions.find_by! generated_by_step_id: redirect_to_step_id
      target_place = target_transition.input_places.first

      if input_place_or_transition.is_a? FlowCore::Transition
        target_place.input_transitions << input_place_or_transition
      else
        input_place_or_transition.input_arcs.update place: target_place
        input_place_or_transition.reload.destroy!
      end

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
