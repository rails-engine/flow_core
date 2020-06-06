class << self
  attr_accessor :stdout_buffer
end

SCRIPT__TOP = self
SCRIPT__TOP.stdout_buffer = ""

module Kernel
  def puts(*args)
    if args.any?
      args.each do |arg|
        SCRIPT__TOP.stdout_buffer << "#{arg}\n"
      end
    else
      SCRIPT__TOP.stdout_buffer << "\n"
    end

    nil
  end
end
