# frozen_string_literal: true

module FlowCore::Steps
  class ParallelSplit < FlowCore::Step
    def deploy_to_workflow!(workflow, input_transition)
      return input_transition if branches.empty?

      input_place = find_or_create_input_place(workflow, input_transition)
      parallel_split_transition =
        input_place.output_transitions.create! workflow: workflow,
                                               name: name,
                                               auto_finish_strategy: "synchronously",
                                               generated_by_step_id: id
      synchronization_transition =
        workflow.transitions.create! workflow: workflow,
                                     name: I18n.t("flow_core.pipeline.synchronization_transition_name"),
                                     auto_finish_strategy: "synchronously"

      deploy_branches_to(workflow, parallel_split_transition, synchronization_transition)

      synchronization_transition
    end

    class << self
      def creatable?
        true
      end

      def multi_branch_step?
        true
      end

      def branch_configurable?
        true
      end

      def barrier_step?
        true
      end
    end
  end
end
