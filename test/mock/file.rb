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
          data = "".b

          loop do
            begin
              data << source_io.readpartial(PORTION_LENGTH)
            rescue ::EOFError
              break
            end

            result, remainder = Common.native_compress data
            data = remainder

            destination_io.write result
          end

          raise ValidateError, "data is not empty" unless data.empty?

          nil
        end

        def self.native_decompress_io(source_io, destination_io, _options)
          data = "".b

          loop do
            begin
              data << source_io.readpartial(PORTION_LENGTH)
            rescue ::EOFError
              break
            end

            result, remainder = Common.native_decompress data
            data = remainder

            destination_io.write result
          end

          raise ValidateError, "data is not empty" unless data.empty?

          nil
        end
      end
    end
  end
end
