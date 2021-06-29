# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

require_relative "char"

module ADSP
  module Stream
    module ReaderHelpers
      module Codepoint
        include Char

        def getcodepoint
          char = getc
          return nil if char.nil?

          char.ord
        end

        def each_codepoint(&block)
          each_data method(:getcodepoint), &block
        end

        alias codepoints each_codepoint

        def readcodepoint
          read_data method(:getcodepoint)
        end

        def ungetcodepoint(code)
          Validation.validate_string_or_integer code

          code = code.chr if code.is_a? ::Integer
          unget_string code
        end
      end
    end
  end
end
