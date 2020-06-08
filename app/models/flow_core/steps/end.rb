# frozen_string_literal: true

module FlowCore::Steps
  class End < FlowCore::Step
    def deploy_to_workflow!(workflow, input_place_or_transition)
      target_place = workflow.end_place || workflow.create_end_place!

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
        false
      end
    end
  end
end
