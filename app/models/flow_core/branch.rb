# frozen_string_literal: true

module FlowCore
  class Branch < FlowCore::ApplicationRecord
    self.table_name = "flow_core_branches"

    belongs_to :pipeline, class_name: "FlowCore::Pipeline"
    belongs_to :step, class_name: "FlowCore::Step"

    has_many :arc_guards, class_name: "FlowCore::ArcGuard", dependent: :destroy

    has_many :steps, -> { order(position: :asc) },
             class_name: "FlowCore::Step", inverse_of: :branch,
             dependent: :destroy

    validates :name,
              presence: true

    validates :fallback_branch,
              uniqueness: {
                scope: %i[step_id]
              }, if: :fallback_branch?

    before_validation do
      self.pipeline ||= step.pipeline
    end

    def user_destroyable?
      !fallback_branch || (fallback_branch? && !step.fallback_branch_required?)
    end

    def arc_guard_attachable?
      !fallback_branch? && step.branch_arc_guard_attachable?
    end

    def copy_arc_guards_to(arc)
      return unless arc_guard_attachable?

      arc_guards.find_each do |arc_guard|
        new_guard = arc_guard.dup
        new_guard.arc = arc
        new_guard.pipeline = nil
        new_guard.branch = nil
        new_guard.save!
      end
    end
  end
end
