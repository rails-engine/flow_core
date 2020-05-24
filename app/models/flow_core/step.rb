# frozen_string_literal: true

module FlowCore
  class Step < FlowCore::ApplicationRecord
    self.table_name = "flow_core_steps"

    has_many :generated_transitions,
             class_name: "FlowCore::Transition", foreign_key: :generated_by_step_id,
             inverse_of: :generated_by, dependent: :nullify

    belongs_to :pipeline, class_name: "FlowCore::Pipeline"
    belongs_to :branch, class_name: "FlowCore::Branch", optional: true

    has_many :branches, class_name: "FlowCore::Branch", inverse_of: :step, dependent: :destroy
    belongs_to :redirect_to_step, class_name: "FlowCore::Step", optional: true
    has_one :transition_trigger, class_name: "FlowCore::TransitionTrigger", dependent: :destroy
    has_many :transition_callbacks, class_name: "FlowCore::TransitionCallback", dependent: :destroy

    extend Ancestry::HasAncestry
    has_ancestry orphan_strategy: :restrict

    extend ActiveRecord::Acts::List::ClassMethods
    acts_as_list scope: %i[pipeline_id branch_id]

    validates :name,
              presence: true

    validates :type,
              presence: true

    validates :redirect_to_step,
              inclusion: {
                in: :redirectable_steps
              },
              allow_nil: true

    validate do
      if branch && branch.pipeline_id != pipeline_id
        errors.add :branch, :invalid
      end

      if redirect_to_step && redirect_to_step.pipeline_id != pipeline_id
        errors.add :redirect_to_step, :invalid
      end

      if redirection_step?
        if !branch
          errors.add :type, :invalid
        elsif branch.fallback_branch?
          errors.add :type, :invalid
        end
      end
    end

    before_validation do
      self.pipeline ||= branch&.pipeline
    end

    before_save :update_parent
    before_save :update_verified

    after_create :reorder_by_append_to_on_create

    attr_accessor :append_to

    def deploy_to_workflow!(_workflow, _input_place_or_transition)
      raise NotImplementedError
    end

    def redirection_step?
      self.class.redirection_step?
    end

    def multi_branch_step?
      self.class.multi_branch_step?
    end

    def transition_trigger_attachable?
      !multi_branch_step?
    end

    def transition_callback_attachable?
      !multi_branch_step?
    end

    def branch_arc_guard_attachable?
      false
    end

    def must_has_a_fallback_branch?
      false
    end

    def barrier_step?
      self.class.barrier_step?
    end

    def redirection_configurable?
      self.class.redirection_configurable?
    end

    def branch_configurable?
      self.class.branch_configurable?
    end

    def redirectable_steps
      redirectable_steps = []

      ancestors.reverse_each do |step|
        break if step.barrier_step?

        redirectable_steps << step
      end

      if redirectable_steps.reject!(&:root?)
        redirectable_steps.concat pipeline.steps
      end
      redirectable_steps.map! do |step|
        if step.parent_of? self
          [step].concat step.children.where.not(branch_id: branch_id)
        else
          [step].concat step.children
        end
      end
      redirectable_steps.flatten!
      redirectable_steps.delete self

      redirectable_steps
    end

    class << self
      def multi_branch_step?
        false
      end

      def redirection_step?
        false
      end

      def barrier_step?
        false
      end

      def redirection_configurable?
        false
      end

      def branch_configurable?
        false
      end
    end

    private

      def update_verified
        self.verified = errors.empty?
      end

      def find_or_create_input_place(workflow, input_place_or_transition)
        if input_place_or_transition.is_a? FlowCore::Transition
          input_place_or_transition.output_places.create! workflow: workflow
        elsif input_place_or_transition.is_a? FlowCore::Place
          input_place_or_transition
        elsif workflow.start_place
          workflow.start_place
        else
          workflow.create_start_place!
        end
      end

      def copy_transition_trigger_to(transition)
        return unless transition_trigger_attachable?
        return unless transition_trigger

        trigger = transition_trigger.dup
        trigger.transition = transition
        trigger.pipeline = nil
        trigger.step = nil

        trigger.save!
      end

      def copy_transition_callbacks_to(transition)
        return unless transition_callback_attachable?

        transition_callbacks.find_each do |cb|
          new_cb = cb.dup
          new_cb.transition = transition
          new_cb.pipeline = nil
          new_cb.step = nil
          new_cb.save!
        end
      end

      def deploy_branches_to(workflow, input_transition, append_to_place_or_transition)
        return unless multi_branch_step?

        branches.includes(:steps, :arc_guards).find_each do |branch|
          if branch.steps.empty?
            if append_to_place_or_transition.is_a?(FlowCore::Place)
              arc = input_transition.output_arcs.create! place: append_to_place_or_transition, fallback_arc: branch.fallback_branch?
            else
              place = workflow.places.create! workflow: workflow
              arc = append_to_place_or_transition.input_arcs.create! place: place, fallback_arc: branch.fallback_branch?
            end
            branch.copy_arc_guards_to arc

            next
          end

          place = workflow.places.create! workflow: workflow
          arc = input_transition.output_arcs.create! place: place, fallback_arc: branch.fallback_branch?
          branch.copy_arc_guards_to arc

          place_or_transition = nil
          branch.steps.each do |step|
            place_or_transition = step.deploy_to_workflow!(workflow, place_or_transition || place)
          end
          next unless place_or_transition

          if place_or_transition.is_a? FlowCore::Transition
            if append_to_place_or_transition.is_a?(FlowCore::Place)
              place_or_transition.output_places << append_to_place_or_transition
            else
              place = place_or_transition.output_places.create! workflow: workflow
              place.output_transitions << append_to_place_or_transition
            end
          elsif append_to_place_or_transition.is_a?(FlowCore::Place)
            place_or_transition.input_arcs.update place: append_to_place_or_transition
            place_or_transition.reload.destroy!
          else
            place_or_transition.output_places << append_to_place_or_transition
          end
        end
      end

      def reorder_by_append_to_on_create
        return unless append_to

        if append_to.to_s == "start"
          move_to_top
          return
        end

        append_to_step = self.class.find_by id: append_to
        return unless append_to_step && append_to_step.branch_id == branch_id

        insert_at(append_to_step.position + 1)
      end

      def update_parent
        self.parent = branch&.step
      end
  end
end
