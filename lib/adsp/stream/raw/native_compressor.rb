# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

require_relative "../../error"

module ADSP
  module Stream
    module Raw
      # ADSP::Stream::Raw::NativeCompressor class.
      class NativeCompressor
        # :nocov:

        # Initializes native compressor.
        # Option: +:destination_buffer_length+ destination buffer length.
        def initialize(options)
          raise NotImplementedError
        end

        # Writes part of +source+ string.
        # Returns array of 2 values:
        # 1. number of bytes written from +source+.
        # 2. boolean that can be named as "need more destination".
        # User needs to call +read_result+ if "need more destination" is true.
        def write(source)
          raise NotImplementedError
        end

        # Provides next part of unread result.
        # Returns empty string if there is no unread result.
        def read_result
          raise NotImplementedError
        end

        # Flushes internal buffers and prepares result for +read_result+.
        # Returns boolean that can be named as "need more destination".
        # User needs to call +read_result+ if "need more destination" is true.
        def flush
          raise NotImplementedError
        end

        # Finishes compressor and prepares result for +read_result+.
        # Returns boolean that can be named as "need more destination".
        # User needs to call +read_result+ if "need more destination" is true.
        def finish
          raise NotImplementedError
        end

        # Closes compressor and cleans up internal resources.
        # Raises +UsedAfterCloseError+ when used after close.
        def close
          raise NotImplementedError
        end

        # :nocov:
      end
    end
  end
end
