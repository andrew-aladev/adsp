# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

require_relative "delegates"
require_relative "stat"
require_relative "../error"
require_relative "../validation"

module ADSP
  module Stream
    class Abstract
      # Native stream is typically not seekable.
      # We don't need to implement methods like "seek" and "pos=".

      # Typically we may not maintain correspondance between bytes
      #   consumed from source and bytes written to destination.
      # So we are going to consume all source bytes and
      #   maintain buffer with remaining destination data.

      include Delegates

      # Native stream.
      attr_reader :io

      # Native stream status info.
      attr_reader :stat

      # Encoding name for destination data.
      attr_reader :external_encoding

      # Encoding name for source data.
      attr_reader :internal_encoding

      # Transcode options for native stream.
      attr_reader :transcode_options

      # Current offset for source data.
      attr_reader :pos
      alias tell pos

      # Initializes stream using +io+ native stream and +options+.
      # Option: +:external_encoding+ encoding name for destination data.
      # Option: +:internal_encoding+ encoding name for source data.
      # Option: +:transcode_options+ transcode options for data.
      def initialize(io, options = {})
        @raw_stream = create_raw_stream
        @io         = io

        @stat = Stat.new @io.stat if @io.respond_to? :stat

        set_encoding options[:external_encoding], options[:internal_encoding], options[:transcode_options]
        reset_buffer
        reset_io_advise

        @pos = 0
      end

      # Creates raw stream.
      protected def create_raw_stream
        raise NotImplementedError
      end

      # -- buffer --

      # Resets internal source buffer.
      protected def reset_buffer
        @buffer = ::String.new :encoding => ::Encoding::BINARY
      end

      # -- advise --

      # Resets native stream advise.
      protected def reset_io_advise
        # Both compressor and decompressor need sequential io access.
        @io.advise :sequential if @io.respond_to? :advise
      rescue ::Errno::ESPIPE
        # ok
      end

      # Sets access mode for native stream, noop.
      def advise
        # Noop
        nil
      end

      # -- encoding --

      # Sets encoding for source and destination data.
      # First argument: +:external_encoding+ encoding name for destination data.
      # Second argument: +:internal_encoding+ encoding name for source data.
      # Third argument: +:transcode_options+ transcode options for data.
      def set_encoding(*args)
        external_encoding, internal_encoding, transcode_options = process_set_encoding_arguments(*args)

        set_target_encoding :@external_encoding, external_encoding
        set_target_encoding :@internal_encoding, internal_encoding
        @transcode_options = transcode_options

        self
      end

      # Processes encoding for source and destination data.
      # First argument: +:external_encoding+ encoding name for destination data.
      # Second argument: +:internal_encoding+ encoding name for source data.
      # Third argument: +:transcode_options+ transcode options for data.
      protected def process_set_encoding_arguments(*args)
        external_encoding = args[0]

        unless external_encoding.nil? || external_encoding.is_a?(::Encoding)
          Validation.validate_string external_encoding

          # First argument can be "external_encoding:internal_encoding".
          match = %r{(.+?):(.+)}.match external_encoding

          unless match.nil?
            external_encoding = match[0]
            internal_encoding = match[1]

            transcode_options = args[1]
            Validation.validate_hash transcode_options unless transcode_options.nil?

            return [external_encoding, internal_encoding, transcode_options]
          end
        end

        internal_encoding = args[1]
        unless internal_encoding.nil? || internal_encoding.is_a?(::Encoding)
          Validation.validate_string internal_encoding
        end

        transcode_options = args[2]
        Validation.validate_hash transcode_options unless transcode_options.nil?

        [external_encoding, internal_encoding, transcode_options]
      end

      # Sets +value+ for encoding +name+.
      protected def set_target_encoding(name, value)
        unless value.nil? || value.is_a?(::Encoding)
          begin
            value = ::Encoding.find value
          rescue ::ArgumentError
            raise ValidateError, "invalid #{name} encoding"
          end
        end

        instance_variable_set name, value
      end

      # Returns encoding for source data if defined.
      # Returns encoding for destination data if encoding for source data is not defined.
      # Returns binary encoding if encodings for source and destination dara are not defined.
      protected def target_encoding
        return @internal_encoding unless @internal_encoding.nil?
        return @external_encoding unless @external_encoding.nil?

        ::Encoding::BINARY
      end

      # -- etc --

      # Resets stream and source position.
      # Returns zero (offset for source data).
      def rewind
        @raw_stream = create_raw_stream

        @io.rewind if @io.respond_to? :rewind

        reset_buffer
        reset_io_advise

        @pos = 0

        0
      end

      # Closes stream.
      def close
        @io.close if @io.respond_to? :close

        nil
      end

      # Returns whether stream is closed.
      def closed?
        return false unless @raw_stream.closed?

        if @io.respond_to? :closed
          @io.closed?
        else
          true
        end
      end

      # Returns self object.
      def to_io
        self
      end
    end
  end
end
