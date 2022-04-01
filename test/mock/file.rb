# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

require "adsp/file"

require_relative "../common"

module ADSP
  module Test
    module Mock
      class File < ADSP::File
        def self.native_compress_io(source_io, destination_io, _options)
        end

        def self.native_decompress_io(source_io, destination_io, _options)
        end
      end
    end
  end
end
