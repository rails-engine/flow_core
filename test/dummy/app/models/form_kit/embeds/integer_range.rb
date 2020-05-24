# frozen_string_literal: true

module FormKit
  module Embeds
    class IntegerRange < FormKit::VirtualModel
      attribute :begin, :integer
      attribute :end, :integer

      validates :begin, :end,
                numericality: { only_integer: true },
                allow_blank: true

      validates :end,
                numericality: {
                  greater_than: :begin
                },
                allow_blank: true,
                if: -> { self[:begin].present? }
    end
  end
end
