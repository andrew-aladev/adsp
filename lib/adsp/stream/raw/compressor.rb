# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

require_relative "abstract"
require_relative "native_compressor"
require_relative "../../error"
require_relative "../../option"
require_relative "../../validation"

module ADSP
  module Stream
    module Raw
      class Compressor < Abstract
        NativeCompressor = Raw::NativeCompressor
        Option           = ADSP::Option

        BUFFER_LENGTH_NAMES = %i[destination_buffer_length].freeze

        def initialize(options = {})
          options       = self.class::Option.get_compressor_options options, BUFFER_LENGTH_NAMES
          native_stream = self.class::NativeCompressor.new options

          super native_stream
        end

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
              # Compressor write should eat all provided "source" without remainder.
              # :nocov:
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
