# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

require_relative "common"
require_relative "../../validation"

module ADSP
  module Stream
    module ReaderHelpers
      module Codepoint
        include Common

        def getcodepoint
          getc.ord
        end

        def each_codepoint(&block)
          each_data method(:getcodepoint), &block
        end

        alias codepoints each_codepoint

        def readcodepoint
          read_data method(:getcodepoint)
        end

        def ungetcodepoint(code)
          unget_string code.chr
        end
      end
    end
  end
end
