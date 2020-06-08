# frozen_string_literal: true

class Time
  include MessagePack::CoreExt

  private

    def to_msgpack_with_packer(packer)
      packer.write_array to_a[0..5].reverse # [sec, min, hour, day, month, year, wday, yday, isdst, zone]
      packer
    end
end
