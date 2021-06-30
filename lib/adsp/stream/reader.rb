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

      protected def reset_io_remainder
        @io_remainder = ::String.new :encoding => ::Encoding::BINARY
      end

      protected def reset_need_to_flush
        @need_to_flush = false
      end

      # -- synchronous --

      def read(bytes_to_read = nil, out_buffer = nil)
        Validation.validate_not_negative_integer bytes_to_read unless bytes_to_read.nil?
        Validation.validate_string out_buffer unless out_buffer.nil?

        unless bytes_to_read.nil?
          return ::String.new :encoding => ::Encoding::BINARY if bytes_to_read.zero?
          return nil if eof?

          append_io_data @io.read(@source_buffer_length) while @buffer.bytesize < bytes_to_read && !@io.eof?
          flush_io_data if @buffer.bytesize < bytes_to_read

          return read_bytes_from_buffer bytes_to_read, out_buffer
        end

        append_io_data @io.read(@source_buffer_length) until @io.eof?
        flush_io_data

        read_buffer out_buffer
      end

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

      # -- asynchronous --

      def readpartial(bytes_to_read, out_buffer = nil)
        read_more_nonblock(bytes_to_read, out_buffer) { @io.readpartial @source_buffer_length }
      end

      def read_nonblock(bytes_to_read, out_buffer = nil, *options)
        read_more_nonblock(bytes_to_read, out_buffer) { @io.read_nonblock(@source_buffer_length, *options) }
      end

      protected def read_more_nonblock(bytes_to_read, out_buffer, &_block)
        Validation.validate_not_negative_integer bytes_to_read
        Validation.validate_string out_buffer unless out_buffer.nil?

        return ::String.new :encoding => ::Encoding::BINARY if bytes_to_read.zero?

        io_provided_eof_error = false

        if @buffer.bytesize < bytes_to_read
          begin
            append_io_data yield
          rescue ::EOFError
            io_provided_eof_error = true
          end
        end

        flush_io_data if @buffer.bytesize < bytes_to_read
        raise ::EOFError if empty? && io_provided_eof_error

        read_bytes_from_buffer bytes_to_read, out_buffer
      end
    end
  end
end
