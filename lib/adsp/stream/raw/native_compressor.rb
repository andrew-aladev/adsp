# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

require_relative "../../validation"

module ADSP
  module Stream
    module Raw
      class NativeCompressor
        # :nocov:
        def write(source)
          raise NotImplementedError
        end

        def read_result
          raise NotImplementedError
        end

        def flush
          raise NotImplementedError
        end

        def finish
          raise NotImplementedError
        end

        def close
          raise NotImplementedError
        end
        # :nocov:
      end
    end
  end
end
