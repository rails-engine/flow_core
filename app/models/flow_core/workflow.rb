# frozen_string_literal: true

module FlowCore
  class Workflow < FlowCore::ApplicationRecord
    self.table_name = "flow_core_workflows"

    FORBIDDEN_ATTRIBUTES = %i[verified verified_at created_at updated_at].freeze

    has_many :instances, class_name: "FlowCore::Instance", dependent: :destroy

    has_many :arcs, class_name: "FlowCore::Arc", dependent: :destroy
    has_many :places, class_name: "FlowCore::Place", dependent: :delete_all
    has_many :transitions, class_name: "FlowCore::Transition", dependent: :destroy

    has_one :start_place, class_name: "FlowCore::StartPlace", dependent: :delete
    has_one :end_place, class_name: "FlowCore::EndPlace", dependent: :delete

    def create_instance!(attributes = {})
      unless verified?
        raise FlowCore::UnverifiedWorkflow, "Workflow##{id} didn't do soundness check yet."
      end

      instances.create! attributes.with_indifferent_access.except(FlowCore::Instance::FORBIDDEN_ATTRIBUTES)
    end

    def invalid?
      !verified?
    end

    def verify?
      violations.clear

      unless start_place
        violations.add(:start_place, :presence)
      end
      unless end_place
        violations.add(:end_place, :presence)
      end

      return false unless start_place && end_place

      # TODO: Naive implementation for now, Help wanted!

      rgl = to_rgl

      start_place_code = "P_#{start_place.id}"
      end_place_code = "P_#{end_place.id}"

      unless rgl.path?(start_place_code, end_place_code)
        violations.add :end_place, :unreachable
      end

      places.find_each do |p|
        next if p == start_place
        next if p == end_place

        place_code = "P_#{p.id}"

        unless rgl.path?(start_place_code, place_code)
          violations.add p, :unreachable
        end

        unless rgl.path?(place_code, end_place_code)
          violations.add p, :impassable
        end
      end
      transitions.includes(:trigger).find_each do |t|
        transition_code = "T_#{t.id}"

        unless rgl.path?(start_place_code, transition_code)
          violations.add t, :unreachable
        end

        unless rgl.path?(transition_code, end_place_code)
          violations.add t, :impassable
        end

        t.verify violations: violations
      end

      violations.empty?
    end

    def violations
      @violations ||= FlowCore::Violations.new
    end

    def verify_status
      if verified_at.blank?
        :unverified
      elsif verified?
        :verified
      else
        :invalid
      end
    end

    def verify!
      update! verified: verify?, verified_at: Time.zone.now
      violations.empty?
    end

    def reset_workflow_verification!
      update! verified: false, verified_at: nil
    end

    def fork
      new_workflow = dup
      transaction do
        yield new_workflow if block_given?
        new_workflow.save!

        new_transitions = transitions.includes(:trigger, :callbacks).map do |t|
          new_transition = t.dup
          new_transition.workflow = new_workflow
          new_transition.save!

          if t.trigger
            new_trigger = t.trigger.dup
            new_trigger.workflow = new_workflow
            new_trigger.transition = new_transition
            new_trigger.save!
          end

          t.callbacks.find_each do |cb|
            new_cb = cb.dup
            new_cb.workflow = new_workflow
            new_cb.transition = new_transition
            new_cb.save!
          end

          [t.id, new_transition.id]
        end.to_h

        new_places = places.map do |p|
          new_place = p.dup
          new_place.workflow = new_workflow
          new_place.save!

          [p.id, new_place.id]
        end.to_h

        arcs.includes(:guards).find_each do |a|
          new_arc = a.dup
          new_arc.workflow = new_workflow
          new_arc.place_id = new_places[a.place_id]
          new_arc.transition_id = new_transitions[a.transition_id]
          new_arc.save!

          a.guards.find_each do |g|
            new_guard = g.dup
            new_guard.workflow = new_workflow
            new_guard.arc = new_arc
            new_guard.save!
          end
        end

        new_workflow.verify!
      end
      new_workflow
    end

    private

      def to_rgl
        graph = RGL::DirectedAdjacencyGraph.new

        places.find_each do |p|
          graph.add_vertex "P_#{p.id}"
        end

        transitions.find_each do |t|
          graph.add_vertex "T_#{t.id}"
        end

        arcs.find_each do |arc|
          if arc.in?
            graph.add_edge "P_#{arc.place_id}", "T_#{arc.transition_id}"
          else
            graph.add_edge "T_#{arc.transition_id}", "P_#{arc.place_id}"
          end
        end

        graph
      end
  end
end
