# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

require_relative "../../error"

module ADSP
  module Stream
    module Raw
      class NativeDecompressor
        # :nocov:

        # Reads part of +source+ string.
        # Returns array of 2 values:
        # 1. number of bytes read from +source+.
        # 2. boolean that can be named as "need more destination".
        # User needs to call +read_result+ if "need more destination" is true.
        def read(source)
          raise NotImplementedError
        end

        # Provides next part of unread result.
        # Returns empty string if there is no unread result.
        def read_result
          raise NotImplementedError
        end

        # Closes decompressor and cleans up internal resources.
        # Raises +UsedAfterCloseError+ when used after close.
        def close
          raise NotImplementedError
        end

        # :nocov:
      end
    end
  end
end
