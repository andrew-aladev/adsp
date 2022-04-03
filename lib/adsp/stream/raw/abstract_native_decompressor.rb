# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

require_relative "../../error"

module ADSP
  module Stream
    module Raw
      class AbstractNativeDecompressor
        # :nocov:
        def read(source)
          raise NotImplementedError
        end

        def read_result
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