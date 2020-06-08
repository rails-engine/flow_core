# frozen_string_literal: true

class BigDecimal
  include MessagePack::CoreExt

  private

    def to_msgpack_with_packer(packer)
      packer.write_string to_s("F")
      packer
    end
end
