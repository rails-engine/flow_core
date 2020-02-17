# frozen_string_literal: true

module FlowCore
  class EndPlace < FlowCore::Place
    validates :type,
              uniqueness: {
                scope: :workflow
              }

    validates :output_arcs,
              length: { is: 0 }

    def end?
      true
    end
  end
end
