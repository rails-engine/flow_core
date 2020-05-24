# frozen_string_literal: true

module FormKit
  module Embeds
    class DatetimeRange < FormKit::VirtualModel
      attribute :begin, :datetime
      attribute :end, :datetime

      validates :end,
                timeliness: {
                  after: :begin,
                  type: :datetime
                },
                allow_blank: true,
                if: -> { self[:begin].present? }

      def begin=(val)
        super(val.try(:in_time_zone)&.utc)
      end

      def end=(val)
        super(val.try(:in_time_zone)&.utc)
      end
    end
  end
end
