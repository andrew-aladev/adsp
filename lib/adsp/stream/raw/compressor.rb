# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

require_relative "abstract"

module ADSP
  module Stream
    module Raw
      class Compressor < Abstract
        def initialize(options = {})
          super create_native_stream(options)
        end

        # :nocov:
        protected def create_native_stream(options)
          raise NotImplementedError
        end
        # :nocov:

        def write(source, &writer)
          do_not_use_after_close

          Validation.validate_string source
          Validation.validate_proc writer

          total_bytes_written = 0

          loop do
            bytes_written, need_more_destination  = @native_stream.write source
            total_bytes_written                  += bytes_written

            if need_more_destination
              source = source.byteslice bytes_written, source.bytesize - bytes_written
              more_destination(&writer)
              next
            end

            unless bytes_written == source.bytesize
              # :nocov:
              # Compressor write should eat all provided "source" without remainder.
              raise UnexpectedError, "unexpected error"
              # :nocov:
            end

            break
          end

          total_bytes_written
        end

        def flush(&writer)
          do_not_use_after_close

          Validation.validate_proc writer

          loop do
            need_more_destination = @native_stream.flush

            if need_more_destination
              more_destination(&writer)
              next
            end

            break
          end

          super
        end

        def close(&writer)
          return nil if closed?

          Validation.validate_proc writer

          loop do
            need_more_destination = @native_stream.finish

            if need_more_destination
              more_destination(&writer)
              next
            end

            break
          end

          super
        end
      end
    end
  end
end
