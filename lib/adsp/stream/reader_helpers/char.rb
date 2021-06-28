# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

require_relative "byte"

module ADSP
  module Stream
    module ReaderHelpers
      module Char
        include Byte

        def getc
          if @external_encoding.nil?
            byte = getbyte
            return nil if byte.nil?

            char = byte.chr
            return transcode_to_internal char
          end

          char = ::String.new :encoding => ::Encoding::BINARY

          # Read one byte until valid string will appear.
          loop do
            byte = getbyte
            return nil if byte.nil?

            char << byte.chr

            char.force_encoding @external_encoding
            return transcode_to_internal char if char.valid_encoding?

            char.force_encoding ::Encoding::BINARY
          end
        end

        def each_char(&block)
          each_data method(:getc), &block
        end

        alias chars each_char

        def readchar
          read_data method(:getc)
        end

        def ungetc(char)
          Validation.validate_string char

          unget_string char
        end
      end
    end
  end
end
