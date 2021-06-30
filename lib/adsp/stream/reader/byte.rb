# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

require_relative "common"
require_relative "../../validation"

module ADSP
  module Stream
    class Reader
      module Byte
        include Common

        def getbyte
          data = read 1
          return nil if data.nil?

          char = data[0]
          return nil if char.nil?

          char.ord
        end

        def each_byte(&block)
          each_data method(:getbyte), &block
        end

        alias bytes each_byte

        def readbyte
          read_data method(:getbyte)
        end

        def ungetbyte(byte)
          Validation.validate_string_or_integer byte

          byte = byte.chr if byte.is_a? ::Integer
          @buffer.prepend byte

          nil
        end
      end
    end
  end
end
