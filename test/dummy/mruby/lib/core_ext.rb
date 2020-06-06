class FalseClass
  def dup
    self
  end

  def pack
    dup
  end
end

class TrueClass
  def dup
    self
  end

  def pack
    dup
  end
end

class Method
  def dup
    self
  end
end

class NilClass
  def dup
    self
  end

  def pack
    dup
  end
end

class String
  def pack
    dup
  end
end

class Numeric
  def dup
    self
  end

  def pack
    dup
  end
end

class Decimal
  def dup
    self
  end

  def pack
    to_s
  end
end

class Time
  class << self
    attr_accessor :formatted_offset
  end

  def pack
    "#{year}-#{month.to_s.rjust(2, "0")}-#{day.to_s.rjust(2, "0")} #{hour.to_s.rjust(2, "0")}:#{min.to_s.rjust(2, "0")}:#{sec.to_s.rjust(2, "0")} #{utc? ? "UTC" : Time.formatted_offset}".rstrip
  end
end

class Date < Time
  def pack
    "#{year}-#{month}-#{day}"
  end
end

class Symbol
  def dup
    self
  end

  def pack
    dup
  end
end

class Object
  def deep_dup
    dup
  end

  def pack
    raise NotImplementedError, "You need to implement #{self.class}#pack so that it can be output value"
  end
end

class Hash
  def deep_dup
    # Different with Shopify's
    each_with_object(dup) do |(key, value), hash|
      hash[key.deep_dup] = value.deep_dup
    end
  end

  def deep_pack
    each_with_object(dup) do |(key, value), hash|
      hash[key.pack] = value.pack
    end
  end
  alias pack deep_pack
end

class Array
  def deep_dup
    map(&:deep_dup)
  end

  def deep_pack
    map(&:pack)
  end
  alias pack deep_pack
end
