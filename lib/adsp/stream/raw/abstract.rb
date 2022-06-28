# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

require_relative "../../error"
require_relative "../../validation"

module ADSP
  module Stream
    module Raw
      # ADSP::Stream::Raw::Abstract class.
      class Abstract
        # Initializes raw stream using +native_stream+.
        def initialize(native_stream)
          @native_stream = native_stream
          @is_closed     = false
        end

        # -- write --

        # Flushes raw stream and writes next result using +writer+ proc.
        def flush(&writer)
          do_not_use_after_close

          Validation.validate_proc writer

          write_result(&writer)

          nil
        end

        # Writes next result using +writer+ proc and frees destination buffer.
        protected def more_destination(&writer)
          result_bytesize = write_result(&writer)
          raise NotEnoughDestinationError, "not enough destination" if result_bytesize.zero?
        end

        # Writes next result using block.
        protected def write_result(&_writer)
          result = @native_stream.read_result
          yield result

          result.bytesize
        end

        # -- close --

        # Raises error when raw stream is closed.
        protected def do_not_use_after_close
          raise UsedAfterCloseError, "used after close" if closed?
        end

        # Writes next result using +writer+ proc and closes raw stream.
        def close(&writer)
          write_result(&writer)

          @native_stream.close
          @is_closed = true

          nil
        end

        # Returns whether raw stream is closed.
        def closed?
          @is_closed
        end
      end
    end
  end
end
