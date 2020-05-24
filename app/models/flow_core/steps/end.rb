# frozen_string_literal: true

module FlowCore::Steps
  class End < FlowCore::Steps::Redirection
    def deploy_to_workflow!(workflow, input_transition)
      end_place = workflow.end_place || workflow.create_end_place!

      input_transition.output_places << end_place

      nil
    end

    class << self
      def redirection_configurable?
        false
      end
    end
  end
end
