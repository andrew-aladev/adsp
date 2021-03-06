# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

require_relative "abstract"
require_relative "raw/decompressor"
require_relative "reader_helpers"
require_relative "../validation"

module ADSP
  module Stream
    # ADSP::Stream::Reader class.
    class Reader < Abstract
      include ReaderHelpers

      # Default source buffer length.
      DEFAULT_SOURCE_BUFFER_LENGTH = 1 << 18 # 256 KB

      # Current raw stream class.
      RawDecompressor = Raw::Decompressor

      # Current line for source data.
      attr_accessor :lineno

      # Initializes stream using +source_io+ native stream and +options+.
      # Option: +:external_encoding+ encoding name for destination data.
      # Option: +:internal_encoding+ encoding name for source data.
      # Option: +:transcode_options+ transcode options for data.
      def initialize(source_io, options = {}, *args)
        @options = options

        super source_io, *args

        initialize_source_buffer_length
        reset_io_remainder
        reset_need_to_flush

        @lineno = 0
      end

      # Creates raw stream.
      protected def create_raw_stream
        self.class::RawDecompressor.new @options
      end

      # Initializes source buffer length.
      protected def initialize_source_buffer_length
        source_buffer_length = @options[:source_buffer_length]
        Validation.validate_not_negative_integer source_buffer_length unless source_buffer_length.nil?

        if source_buffer_length.nil? || source_buffer_length.zero?
          source_buffer_length = self.class::DEFAULT_SOURCE_BUFFER_LENGTH
        end

        @source_buffer_length = source_buffer_length
      end

      # Resets io remainder.
      protected def reset_io_remainder
        @io_remainder = ::String.new :encoding => ::Encoding::BINARY
      end

      # Resets need to flush flag.
      protected def reset_need_to_flush
        @need_to_flush = false
      end

      # -- synchronous --

      # Reads +bytes_to_read+ bytes from stream.
      # If +out_buffer+ is defined than it will be used as output destination.
      def read(bytes_to_read = nil, out_buffer = nil)
        Validation.validate_not_negative_integer bytes_to_read unless bytes_to_read.nil?
        Validation.validate_string out_buffer unless out_buffer.nil?

        raise ValidateError, "io should be responsible to read and eof" unless
          @io.respond_to?(:read) && @io.respond_to?(:eof?)

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

      # Resets stream.
      def rewind
        raw_wrapper :close

        reset_io_remainder
        reset_need_to_flush

        super
      end

      # Closes stream.
      def close
        raw_wrapper :close

        super
      end

      # Returns whether we are at the end of stream.
      def eof?
        raise ValidateError, "io should be responsible to eof" unless @io.respond_to? :eof?

        empty? && @io.eof?
      end

      # -- asynchronous --

      # Reads +bytes_to_read+ bytes from stream.
      # If +out_buffer+ is defined than it will be used as output destination.
      # Raises +::EOFError+ when no data available.
      def readpartial(bytes_to_read, out_buffer = nil)
        raise ValidateError, "io should be responsible to readpartial" unless @io.respond_to? :readpartial

        read_more_nonblock(bytes_to_read, out_buffer) { @io.readpartial @source_buffer_length }
      end

      # Reads +bytes_to_read+ bytes from stream.
      # If +out_buffer+ is defined than it will be used as output destination.
      # +options+ will be passed to native stream.
      def read_nonblock(bytes_to_read, out_buffer = nil, *options)
        raise ValidateError, "io should be responsible to read nonblock" unless @io.respond_to? :read_nonblock

        read_more_nonblock(bytes_to_read, out_buffer) { @io.read_nonblock(@source_buffer_length, *options) }
      end

      # Reads +bytes_to_read+ bytes from stream.
      # If +out_buffer+ is defined than it will be used as output destination.
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

      # -- common --

      # Appends +io_data+ from native stream to internal storage.
      protected def append_io_data(io_data)
        io_portion    = @io_remainder + io_data
        bytes_read    = raw_wrapper :read, io_portion
        @io_remainder = io_portion.byteslice bytes_read, io_portion.bytesize - bytes_read

        # Even empty io data may require flush.
        @need_to_flush = true
      end

      # Triggers flush method for native stream.
      protected def flush_io_data
        raw_wrapper :flush

        @need_to_flush = false
      end

      # Returns whether stream is empty.
      protected def empty?
        !@need_to_flush && @buffer.bytesize.zero?
      end

      # Reads +bytes_to_read+ bytes from buffer.
      # If +out_buffer+ is defined than it will be used as output destination.
      protected def read_bytes_from_buffer(bytes_to_read, out_buffer)
        bytes_read = [@buffer.bytesize, bytes_to_read].min

        # Result uses buffer binary encoding.
        result   = @buffer.byteslice 0, bytes_read
        @buffer  = @buffer.byteslice bytes_read, @buffer.bytesize - bytes_read
        @pos    += bytes_read

        result = out_buffer.replace result unless out_buffer.nil?
        result
      end

      # Reads data from buffer.
      # If +out_buffer+ is defined than it will be used as output destination.
      protected def read_buffer(out_buffer)
        result = @buffer
        reset_buffer
        @pos += result.bytesize

        result.force_encoding @external_encoding unless @external_encoding.nil?
        result = transcode_to_internal result

        result = out_buffer.replace result unless out_buffer.nil?
        result
      end

      # Transcodes +data+ to internal encoding.
      protected def transcode_to_internal(data)
        data = data.encode @internal_encoding, **@transcode_options unless @internal_encoding.nil?
        data
      end

      # Transcodes +data+ to external encoding.
      # We should be able to return data back to buffer.
      # We won't use any transcode options because transcoded data should be backward compatible.
      protected def transcode_to_external(data)
        data = data.encode @external_encoding unless @external_encoding.nil?
        data
      end

      # Wraps +method_name+ for raw stream.
      protected def raw_wrapper(method_name, *args)
        @raw_stream.send(method_name, *args) { |portion| @buffer << portion }
      end
    end
  end
end
