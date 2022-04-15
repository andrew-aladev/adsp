# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

require "adsp/file"

require_relative "../common"

module ADSP
  module Test
    module Mock
      class File < ADSP::File
        PORTION_LENGTH = 10**6

        def self.native_compress_io(source_io, destination_io, _options)
          loop do
            begin
              data = source_io.readpartial PORTION_LENGTH
            rescue ::EOFError
              break
            end

            result = Common.native_compress data

            destination_io.write result
          end

          nil
        end

        def self.native_decompress_io(source_io, destination_io, _options)
          loop do
            begin
              data = source_io.readpartial PORTION_LENGTH
            rescue ::EOFError
              break
            end

            result = Common.native_decompress data

            destination_io.write result
          end

          nil
        end
      end
    end
  end
end
