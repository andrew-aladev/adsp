# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

require "adsp/string"

require_relative "../common"

module ADSP
  module Test
    module Mock
      class String < ADSP::String
        def self.native_compress_string(source, _options)
          result, remainder = Common.native_compress source
          raise ValidateError, "remainder is not empty" unless remainder.empty?

          result
        end

        def self.native_decompress_string(source, _options)
          result, remainder = Common.native_decompress source
          raise ValidateError, "remainder is not empty" unless remainder.empty?

          result
        end
      end
    end
  end
end
