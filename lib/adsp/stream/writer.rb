# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

require_relative "abstract"
require_relative "raw/compressor"
require_relative "writer_helpers"

module ADSP
  module Stream
    # ADSP::Stream::Writer class.
    class Writer < Abstract
      include WriterHelpers

      # Current raw stream class.
      RawCompressor = Raw::Compressor

      # Initializes stream using +destination_io+ native stream and +options+.
      # Option: +:external_encoding+ encoding name for destination data.
      # Option: +:internal_encoding+ encoding name for source data.
      # Option: +:transcode_options+ transcode options for data.
      def initialize(destination_io, options = {}, *args)
        @options = options

        super destination_io, *args
      end

      # Creates raw stream.
      protected def create_raw_stream
        self.class::RawCompressor.new @options
      end

      # -- synchronous --

      # Writes +objects+ to stream.
      def write(*objects)
        validate_write

        write_remaining_buffer

        bytes_written = 0

        objects.each do |object|
          source         = transcode object.to_s
          bytes_written += raw_wrapper :write, source
        end

        @pos += bytes_written

        bytes_written
      end

      # Flushes stream.
      def flush
        validate_write

        finish :flush

        @io.flush if @io.respond_to? :flush

        self
      end

      # Resets stream.
      def rewind
        validate_write

        finish :close

        super
      end

      # Closes stream.
      def close
        validate_write

        finish :close

        super
      end

      # Finishes stream using +method_name+.
      protected def finish(method_name)
        write_remaining_buffer

        raw_wrapper method_name
      end

      # Writes remaining buffer and resets it.
      protected def write_remaining_buffer
        return nil if @buffer.bytesize.zero?

        @io.write @buffer

        reset_buffer
      end

      # Wraps +method_name+ for raw stream.
      protected def raw_wrapper(method_name, *args)
        @raw_stream.send(method_name, *args) { |portion| @io.write portion }
      end

      # Validates native stream responsibility to +write+ method.
      protected def validate_write
        raise ValidateError, "io should be responsible to write" unless @io.respond_to? :write
      end

      # -- asynchronous --

      # Writes +object+ nonblock.
      # +options+ will be passed to native stream.
      # Native stream +write_nonblock+ can raise +IO::WaitWritable+ error.
      # After resolving this error user may provide same content again.
      # It is not possible to revert accepted content after error.
      # So we have to accept content after processing native stream +write_nonblock+.
      # It means that first write nonblock won't call native stream +write_nonblock+.
      def write_nonblock(object, *options)
        validate_write_nonblock

        return 0 unless write_remaining_buffer_nonblock(*options)

        source         = transcode object.to_s
        bytes_written  = raw_nonblock_wrapper :write, source
        @pos          += bytes_written

        bytes_written
      end

      # Flushes stream nonblock.
      # +options+ will be passed to native stream.
      def flush_nonblock(*options)
        validate_write_nonblock

        return false unless finish_nonblock :flush, *options

        @io.flush if @io.respond_to? :flush

        true
      end

      # Resets stream nonblock.
      # +options+ will be passed to native stream.
      def rewind_nonblock(*options)
        validate_write_nonblock

        return false unless finish_nonblock :close, *options

        method(:rewind).super_method.call

        true
      end

      # Closes stream nonblock.
      # +options+ will be passed to native stream.
      def close_nonblock(*options)
        validate_write_nonblock

        return false unless finish_nonblock :close, *options

        method(:close).super_method.call

        true
      end

      # Finishes stream using +method_name+ nonblock.
      # +options+ will be passed to native stream.
      protected def finish_nonblock(method_name, *options)
        return false unless write_remaining_buffer_nonblock(*options)

        raw_nonblock_wrapper method_name

        write_remaining_buffer_nonblock(*options)
      end

      # Writes remaining buffer nonblock.
      # +options+ will be passed to native stream.
      protected def write_remaining_buffer_nonblock(*options)
        return true if @buffer.bytesize.zero?

        bytes_written = @io.write_nonblock @buffer, *options
        return false if bytes_written.zero?

        @buffer = @buffer.byteslice bytes_written, @buffer.bytesize - bytes_written

        @buffer.bytesize.zero?
      end

      # Wraps nonblock +method_name+ for raw stream.
      protected def raw_nonblock_wrapper(method_name, *args)
        @raw_stream.send(method_name, *args) { |portion| @buffer << portion }
      end

      # Validates native stream responsibility to +write_nonblock+ method.
      protected def validate_write_nonblock
        raise ValidateError, "io should be responsible to write nonblock" unless @io.respond_to? :write_nonblock
      end

      # -- common --

      # Transcodes +data+ to external encoding.
      protected def transcode(data)
        data = data.encode @external_encoding, **@transcode_options unless @external_encoding.nil?
        data
      end
    end
  end
end
