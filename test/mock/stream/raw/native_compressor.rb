# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

require "adsp/error"

require_relative "../../common"

module ADSP
  module Test
    module Mock
      module Stream
        module Raw
          class NativeCompressor
            def initialize(options)
              @source_remainder          = "".b
              @destination_buffer        = "".b
              @destination_buffer_length = options[:destination_buffer_length]

              @is_closed = false
            end

            def write(source)
              do_not_use_after_close

              result, remainder = Common.native_compress(@source_remainder + source)
              bytes_written     = [
                0,
                source.bytesize - remainder.bytesize - @source_remainder.bytesize
              ].max
              @source_remainder = remainder

              [bytes_written]
            end

            def read_result
              do_not_use_after_close

              result              = @destination_buffer
              @destination_buffer = "".b

              result
            end

            def flush
              do_not_use_after_close
            end

            def finish
              do_not_use_after_close
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
