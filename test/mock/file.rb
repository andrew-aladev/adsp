# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

require "adsp/file"

require_relative "./common"

module ADSP
  module Test
    module Mock
      class File < ADSP::File
        PORTION_LENGTH = 10**6

        def self.native_compress_io(source_io, destination_io, options)
          destination_buffer_length = options[:destination_buffer_length]
          source                    = "".b

          loop do
            begin
              source << source_io.readpartial(PORTION_LENGTH)
            rescue ::EOFError
              break
            end

            until source.empty?
              data, bytes_read = Common.native_compress source, destination_buffer_length
              source = source.byteslice bytes_read, source.bytesize - bytes_read

              destination_io.write data
            end
          end

          nil
        end

        def self.native_decompress_io(source_io, destination_io, options)
          destination_buffer_length = options[:destination_buffer_length]
          source                    = "".b

          loop do
            begin
              source << source_io.readpartial(PORTION_LENGTH)
            rescue ::EOFError
              break
            end

            until source.empty?
              data, bytes_read = Common.native_decompress source, destination_buffer_length
              source = source.byteslice bytes_read, source.bytesize - bytes_read

              destination_io.write data
            end
          end

          nil
        end
      end
    end
  end
end
