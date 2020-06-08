# frozen_string_literal: true

class Date
  include MessagePack::CoreExt

  private

    def to_msgpack_with_packer(packer)
      packer.write_array [year, month, day]
      packer
    end
end
