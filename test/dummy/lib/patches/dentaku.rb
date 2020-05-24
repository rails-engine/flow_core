# frozen_string_literal: true

require "bigdecimal"

module Dentaku
  module AST
    module StringFunctions
      class ToInteger < Base
        def self.min_param_count
          1
        end

        def self.max_param_count
          1
        end

        def initialize(*args)
          super
          @string = @args[0]
        end

        def value(context = {})
          string = @string.value(context).to_s
          Integer(string)
        end

        def type
          :numeric
        end
      end

      class ToFloat < Base
        def self.min_param_count
          1
        end

        def self.max_param_count
          1
        end

        def initialize(*args)
          super
          @string = @args[0]
        end

        def value(context = {})
          string = @string.value(context).to_s
          Float(string)
        end

        def type
          :numeric
        end
      end

      class ToDecimal < Base
        def self.min_param_count
          1
        end

        def self.max_param_count
          1
        end

        def initialize(*args)
          super
          @string = @args[0]
        end

        def value(context = {})
          string = @string.value(context).to_s
          BigDecimal(string)
        end

        def type
          :numeric
        end
      end
    end
  end
end

Dentaku::AST::Function.register_class(:to_i, Dentaku::AST::StringFunctions::ToInteger)
Dentaku::AST::Function.register_class(:to_f, Dentaku::AST::StringFunctions::ToFloat)
Dentaku::AST::Function.register_class(:to_d, Dentaku::AST::StringFunctions::ToDecimal)
