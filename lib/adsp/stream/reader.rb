# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

require_relative "abstract"
require_relative "raw/decompressor"
require_relative "reader_helpers"
require_relative "../validation"

module ADSP
  module Stream
    class Reader < Abstract
      include ReaderHelpers

      DEFAULT_SOURCE_BUFFER_LENGTH = 1 << 18 # 256 KB

      def initialize(source_io, options = {}, *args)
        @options = options

        super source_io, *args

        initialize_source_buffer_length
        reset_io_remainder
        reset_need_to_flush

        @lineno = 0
      end

      protected def initialize_source_buffer_length
        source_buffer_length = @options[:source_buffer_length]
        Validation.validate_not_negative_integer source_buffer_length unless source_buffer_length.nil?

        if source_buffer_length.nil? || source_buffer_length.zero?
          source_buffer_length = self.class::DEFAULT_SOURCE_BUFFER_LENGTH
        end

        @source_buffer_length = source_buffer_length
      end

      # -- synchronous --

      def reopen(*args)
        raw_wrapper :close

        reset_io_remainder
        reset_need_to_flush

        super
      end

      def rewind
        raw_wrapper :close

        reset_io_remainder
        reset_need_to_flush

        super
      end

      def close
        raw_wrapper :close

        super
      end

      def eof?
        empty? && @io.eof?
      end
    end
  end
end
