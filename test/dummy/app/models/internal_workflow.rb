# frozen_string_literal: true

class InternalWorkflow < FlowCore::Workflow
  def internal?
    true
  end

  class << self
    def find_or_deploy_leave_flow
      workflow = FlowCore::Workflow.where(tag: "leave").order(created_at: :desc).first
      return workflow if workflow

      FlowCore::Definition.new name: "Leave", tag: "leave", type: InternalWorkflow do |net|
        net.start_place :start, name: "Start"
        net.end_place :end, name: "End"

        net.transition :leader_evaluate,
                       name: "Leader Evaluate",
                       with_trigger: "TransitionTriggers::ApprovalTask",
                       with_callback: "TransitionCallbacks::Notification",
                       input: :start do |t|
          t.output :leader_approved, name: "Leader Approved", with_guard: { name: "Approved", type: "ArcGuards::Dentaku", expression: "approved" }
          t.output :rejected, name: "Rejected", with_guard: { name: "Rejected", type: "ArcGuards::Dentaku", expression: "NOT(approved)" }
        end

        net.transition :hr_evaluate,
                       name: "HR Evaluate",
                       with_trigger: { type: "TransitionTriggers::ApprovalTask" },
                       with_callbacks: [{ type: "TransitionCallbacks::Notification" }],
                       input: :leader_approved do |t|
          t.output :hr_approved, name: "HR Approved", with_guard: { name: "Approved", type: "ArcGuards::Dentaku", expression: "approved" }
          t.output :rejected, with_guard: { name: "Rejected", type: "ArcGuards::Dentaku", expression: "NOT(approved)" }
        end

        net.transition :report_back, name: "Report Back", with_trigger: TransitionTriggers::UserTask, input: :hr_approved, output: :end do |t|
          t.with_callback TransitionCallbacks::Notification
        end

        net.transition :resend_request, name: "Resend Request", input: :rejected do |t|
          t.with_trigger TransitionTriggers::UserTask
          t.with_callbacks ["TransitionCallbacks::Notification"]
          t.output :start
          t.output :end, with_guard: { type: "ArcGuards::Dentaku", name: "Discard", expression: "discard" }
        end
      end.deploy!
    end
  end
end
