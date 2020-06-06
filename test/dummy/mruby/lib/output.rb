module Output
  class << self
    attr_accessor :value

    def pack
      value.pack
    end
  end
end
