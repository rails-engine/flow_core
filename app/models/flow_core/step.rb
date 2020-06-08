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
    after_destroy :recheck_redirection_steps_on_destroy

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
      !multi_branch_step? && !redirection_step?
    end

    def transition_callback_attachable?
      !multi_branch_step?
    end

    def branch_arc_guard_attachable?
      false
    end

    def fallback_branch_required?
      false
    end

    def transition_trigger_required?
      self.class.transition_trigger_required?
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
      return [] unless redirection_step?

      redirectable_steps = []

      # Barrier step is the stop point, beyond if can't ensure the workflow valid
      # e.g. consider there's a redirection step in one of branch of a parallel branch step,
      # the parallel branch step is the barrier step, if redirect beyond the barrier step,
      # it will multiplex all branches again and again
      # Barrier step 是保障流程的边界，如果重定向到边界外的节点，就无法保证流程合法，
      # 一个例子是假设并发分支步骤的某个分支里有一个重定向节点，并发分支步骤就是一个 Barrier Step，
      # 如果可以重定向到并发分支步骤外，重定向到步骤后会重新执行这个并发分支步骤，导致其他分支的步骤会被无限重复执行
      ancestors.reverse_each do |step|
        break if step.barrier_step?

        redirectable_steps << step
      end

      # return an empty array if there's no safe ancestor,
      # redirect to steps which in current branch in not safe, because it will infinite loop
      # 如果一个安全的祖先步骤都没有，就返回空集，跳到当前分支的步骤会导致死循环或者死代码，没有意义
      return [] if redirectable_steps.empty?

      # if the redirection step is the first step of a branch,
      # avoiding redirect to parent and ancestors which are first step (of a branch) and without a transition trigger,
      # because it will lead infinite loop,
      # 如果重定向步骤是分支的第一步，那么父步骤和其他也是处于（分支）第一步的祖先，也都要避免跳转，因为会导致死循环
      if position == 1 && redirectable_steps.any?
        if redirectable_steps.first.multi_branch_step? && !redirectable_steps.first.transition_trigger
          redirectable_steps.shift
        end

        while redirectable_steps.any?
          step = redirectable_steps.first
          if step.multi_branch_step? && !redirectable_steps.first.transition_trigger
            redirectable_steps.shift

            if step.position > 1
              break
            end
          else
            break
          end
        end
      end

      # It's safe to redirect to any top level (or main branch) steps,
      # just avoiding the redirect step's ancestor, because it may lead infinite loop
      # 跳到顶层（或者说主干）步骤都是安全的，只是要去掉跳转步骤的祖先，因为会导致死循环
      if redirectable_steps.reject!(&:root?)
        redirectable_steps.concat(pipeline.steps)
      elsif redirectable_steps.empty?
        redirectable_steps.concat(pipeline.steps - ancestors)
      end

      # It's also safe to redirect to any of children steps,
      # just avoid current branch which the redirection step belongs to.
      # 跳转到任何步骤的分支也都是安全的，就是要避免分支是当前跳转步骤的祖先步骤
      redirectable_steps.map! do |s|
        if s.parent_of? self
          [s].concat s.children.where.not(branch_id: branch_id)
        else
          [s].concat s.children
        end
      end
      redirectable_steps.flatten!
      redirectable_steps.uniq!
      redirectable_steps.reject!(&:redirection_step?)

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

      def transition_trigger_required?
        false
      end
    end

    private

      def update_verified
        self.verified = valid?
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

      def recheck_redirection_steps_on_destroy
        return unless branch

        branch.steps.to_a.select(&:redirection_step?).each do |step|
          unless step.redirectable_steps.include? step.redirect_to_step
            step.update! redirect_to_step: nil
          end
        end
      end

      def update_parent
        self.parent = branch&.step
      end
  end
end
