# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

require_relative "abstract"

module ADSP
  module Stream
    module Raw
      class Decompressor < Abstract
        def initialize(options = {})
          super create_native_stream(options)
        end

        # :nocov:
        protected def create_native_stream(options)
          raise NotImplementedError
        end
        # :nocov:

        def read(source, &writer)
          do_not_use_after_close

          Validation.validate_string source
          Validation.validate_proc writer

          total_bytes_read = 0

          loop do
            bytes_read, need_more_destination  = @native_stream.read source
            total_bytes_read                  += bytes_read

            if need_more_destination
              source = source.byteslice bytes_read, source.bytesize - bytes_read
              more_destination(&writer)
              next
            end

            break
          end

          # Please remember that "total_bytes_read" can not be equal to "source.bytesize".
          total_bytes_read
        end

        def flush(&writer)
          do_not_use_after_close

          Validation.validate_proc writer

          super
        end

        def close(&writer)
          return nil if closed?

          Validation.validate_proc writer

          super
        end
      end
    end
  end
end
