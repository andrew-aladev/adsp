# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

require "adsp/string"

require_relative "../common"

module ADSP
  module Test
    module Mock
      class String < ADSP::String
        def self.native_compress_string(source, _options)
          native_process_string source
        end

        def self.native_decompress_string(source, _options)
          native_process_string source
        end

        private_class_method def self.native_process_string(data)
          Common.flip_bytes data
        end
      end
    end
  end
end
