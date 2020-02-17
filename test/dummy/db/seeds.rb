# frozen_string_literal: true

FlowCore::Definition.new name: "Simple sequence" do |net|
  net.start_place :start, name: "Start"
  net.end_place :end, name: "End"

  net.transition :t1, input: :start, output: :p1
  net.transition :t2, input: :p1, output: :end
end.deploy!

FlowCore::Definition.new name: "Parallel routing" do |net|
  net.start_place :start
  net.end_place :end

  net.transition :t1, input: :start, output: %i[p1 p2]
  net.transition :t2, input: :p1, output: :p3
  net.transition :t3, input: :p2, output: :p4
  net.transition :t4, input: %i[p3 p4], output: :end
end.deploy!

FlowCore::Definition.new name: "Timed split" do |net|
  net.start_place :start
  net.end_place :end

  net.transition :t1, input: :start, output: :p
  net.transition :t2, input: :p, output: :end
  net.transition :t3, input: :start, output: :end do |t|
    t.with_trigger TransitionTriggers::Timer,
                   countdown_in_seconds: 5
  end
end.deploy!

InternalWorkflow.find_or_deploy_leave_flow

w = FlowCore::Workflow.first
i = w.create_instance!
i.active!
t = i.tasks.enabled.first
t.finish!
t = i.tasks.enabled.first
t.finish!
