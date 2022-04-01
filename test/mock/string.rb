# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

require "adsp/string"

require_relative "../common"

module ADSP
  module Test
    module Mock
      class String < ADSP::String
        def self.native_compress_string(source, _options)
          Common.flip_bytes source
        end

        def self.native_decompress_string(source, _options)
          Common.flip_bytes source
        end
      end
    end
  end
end
