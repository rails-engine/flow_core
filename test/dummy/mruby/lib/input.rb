module Input
  class << self
    def load(input)
      @input = input || {}
      @input.freeze
    end

    def value
      @input
    end

    def pack
      @input.pack
    end

    def [](key)
      @input[key]
    end

    def each(*args, &block)
      @input.each(*args, &block)
    end

    def map(*args, &block)
      @input.map(*args, &block)
    end

    def to_s
      @input.to_s
    end
  end
end
