# frozen_string_literal: true

module FormKit
  module Embeds
    class DecimalRange < FormKit::VirtualModel
      attribute :begin, :decimal
      attribute :end, :decimal

      validates :begin, :end,
                numericality: { only_integer: false },
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
