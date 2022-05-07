# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

require "adsp/error"
require "adsp/validation"

require_relative "../../common"

module ADSP
  module Test
    module Mock
      module Stream
        module Raw
          class NativeDecompressor
            def initialize(options)
              ADSP::Validation.validate_hash options

              destination_buffer_length = options[:destination_buffer_length]
              ADSP::Validation.validate_not_negative_integer destination_buffer_length

              destination_buffer_length = Common::DEFAULT_DESTINATION_BUFFER_LENGTH \
                if destination_buffer_length.zero?

              @destination_buffer        = "".b
              @destination_buffer_length = destination_buffer_length

              @is_closed = false
            end

            def read(source)
              ADSP::Validation.validate_string source

              do_not_use_after_close

              remaining_destination_buffer_length = @destination_buffer_length - @destination_buffer.bytesize
              data, bytes_read = Common.native_decompress source, remaining_destination_buffer_length
              needs_more_destination = bytes_read < source.bytesize
              @destination_buffer << data

              [bytes_read, needs_more_destination]
            end

            def read_result
              do_not_use_after_close

              result              = @destination_buffer
              @destination_buffer = "".b

              result
            end

            def close
              do_not_use_after_close

              @is_closed = true

              nil
            end

            protected def do_not_use_after_close
              raise UsedAfterCloseError if @is_closed
            end
          end
        end
      end
    end
  end
end
