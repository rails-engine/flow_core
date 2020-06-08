# frozen_string_literal: true

module FlowCore::Steps
  class ExclusiveChoice < FlowCore::Step
    after_create :auto_create_fallback_branch

    def deploy_to_workflow!(workflow, input_transition)
      return input_transition if branches.empty?

      input_place = find_or_create_input_place(workflow, input_transition)
      exclusive_choice_transition =
        if transition_trigger
          t = input_place.output_transitions.create! workflow: workflow,
                                                     name: name,
                                                     output_token_create_strategy: :match_one_or_fallback,
                                                     generated_by_step_id: id
          copy_transition_trigger_to t
          copy_transition_callbacks_to t
          t
        else
          input_place.output_transitions.create! workflow: workflow,
                                                 name: name,
                                                 output_token_create_strategy: :match_one_or_fallback,
                                                 auto_finish_strategy: "synchronously",
                                                 generated_by_step_id: id
        end

      simple_merge_place = workflow.places.create! workflow: workflow

      deploy_branches_to(workflow, exclusive_choice_transition, simple_merge_place)

      simple_merge_place
    end

    def transition_trigger_attachable?
      true
    end

    def branch_arc_guard_attachable?
      true
    end

    def fallback_branch_required?
      true
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
    end

    private

      def auto_create_fallback_branch
        branches.create! name: I18n.t("flow_core.pipeline.fallback_branch_name"),
                         fallback_branch: true
      end
  end
end
