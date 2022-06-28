# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

require_relative "abstract"
require_relative "native_decompressor"
require_relative "../../option"
require_relative "../../validation"

module ADSP
  module Stream
    module Raw
      # ADSP::Stream::Raw::Decompressor class.
      class Decompressor < Abstract
        # Current native decompressor class.
        NativeDecompressor = Raw::NativeDecompressor

        # Current option class.
        Option = ADSP::Option

        # Current buffer length names.
        # It is a part of decompressor options.
        BUFFER_LENGTH_NAMES = %i[destination_buffer_length].freeze

        # Initializes decompressor.
        # Option: +:destination_buffer_length+ destination buffer length.
        def initialize(options = {})
          options       = self.class::Option.get_decompressor_options options, BUFFER_LENGTH_NAMES
          native_stream = self.class::NativeDecompressor.new options

          super native_stream
        end

        # Reads +source+ string, writes result using +writer+ proc.
        # Returns amount of bytes read from +source+.
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

          total_bytes_read
        end

        # Flushes decompressor, writes result using +writer+ proc and closes decompressor.
        def flush(&writer)
          do_not_use_after_close

          Validation.validate_proc writer

          super
        end

        # Writes result using +writer+ proc and closes decompressor.
        # Raises +UsedAfterCloseError+ when used after close.
        def close(&writer)
          return nil if closed?

          Validation.validate_proc writer

          super
        end
      end
    end
  end
end
