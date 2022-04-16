# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

require "adsp/error"

require_relative "../../../common"

module ADSP
  module Test
    module Mock
      module Stream
        module Raw
          class NativeDecompressor
            def initialize(options)
              @destination_buffer        = "".b
              @destination_buffer_length = options[:destination_buffer_length]

              @is_closed = false
            end

            def read(source)
              bytes_read             = @destination_buffer_length - @destination_buffer.bytesize
              needs_more_destination = !bytes_read == source.bytesize

              portion = source.byteslice 0, bytes_read
              @destination_buffer << Common.flip_bytes(portion)

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