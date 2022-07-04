# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

require "adsp/string"

require_relative "./common"

module ADSP
  module Test
    module Mock
      # ADSP::Test::Mock::String class.
      class String < ADSP::String
        def self.native_compress_string(source, options)
          destination_buffer_length = options[:destination_buffer_length]
          result                    = "".b

          loop do
            data, bytes_read = Common.native_compress source, destination_buffer_length
            source = source.byteslice bytes_read, source.bytesize - bytes_read
            result << data

            break if source.bytesize.zero?
          end

          result
        end

        def self.native_decompress_string(source, options)
          destination_buffer_length = options[:destination_buffer_length]
          result                    = "".b

          loop do
            data, bytes_read = Common.native_decompress source, destination_buffer_length
            source = source.byteslice bytes_read, source.bytesize - bytes_read
            result << data

            break if source.bytesize.zero?
          end

          result
        end
      end
    end
  end
end
