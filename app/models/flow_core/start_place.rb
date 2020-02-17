# frozen_string_literal: true

module FlowCore
  class StartPlace < FlowCore::Place
    validates :type,
              uniqueness: {
                scope: :workflow
              }

    validates :input_arcs,
              length: { is: 0 }

    def start?
      true
    end
  end
end
