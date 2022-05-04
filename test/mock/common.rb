# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

require "adsp/string"

require_relative "../common"

module ADSP
  module Test
    module Mock
      module Common
        DEFAULT_DESTINATION_BUFFER_LENGTH = 1 << 18 # 256 KB

        # Flipping bytes and packing them as 16-bit values in network byte order.
        # This method will make compressed data bytesize more than original bytesize.
        # It will help to improve testing coverage.
        def self.native_compress(source, destination_buffer_length)
          source_length             = source.bytesize
          destination_buffer_length = DEFAULT_DESTINATION_BUFFER_LENGTH if destination_buffer_length.zero?

          bytes_read =
            if destination_buffer_length.nil?
              source_length
            else
              [source_length, destination_buffer_length / 2].min
            end

          result = source
            .byteslice(0, bytes_read)
            .unpack("C*")
            .map { |byte| byte ^ 0xFF }
            .pack "n*"
          [result, bytes_read]
        end

        def self.native_decompress(source, destination_buffer_length)
          source_length             = source.bytesize / 2 * 2
          destination_buffer_length = DEFAULT_DESTINATION_BUFFER_LENGTH if destination_buffer_length.zero?

          bytes_read =
            if destination_buffer_length.nil?
              source_length
            else
              [source_length, destination_buffer_length * 2].min
            end

          result = source
            .byteslice(0, bytes_read)
            .unpack("n*")
            .map { |byte| byte ^ 0xFF }
            .pack "C*"
          [result, bytes_read]
        end
      end
    end
  end
end
