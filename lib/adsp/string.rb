# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

require_relative "error"
require_relative "option"
require_relative "validation"

module ADSP
  class String
    # Current option class.
    Option = ADSP::Option

    # Current buffer length names.
    # It is a part of decompressor options.
    BUFFER_LENGTH_NAMES = %i[destination_buffer_length].freeze

    # Compresses +source+ string using +options+.
    # Option: +:destination_buffer_length+ destination buffer length.
    # Returns compressed string.
    def self.compress(source, options = {})
      Validation.validate_string source

      options = self::Option.get_compressor_options options, BUFFER_LENGTH_NAMES

      native_compress_string source, options
    end

    # :nocov:

    # Internal method for compressing +source+ string using +options+.
    def self.native_compress_string(source, options)
      raise NotImplementedError
    end

    # :nocov:

    # Decompresses +source+ string using +options+.
    # Option: +:destination_buffer_length+ destination buffer length.
    # Returns decompressed string.
    def self.decompress(source, options = {})
      Validation.validate_string source

      options = self::Option.get_decompressor_options options, BUFFER_LENGTH_NAMES

      native_decompress_string source, options
    end

    # :nocov:

    # Internal method for decompressing +source+ string using +options+.
    def self.native_decompress_string(source, options)
      raise NotImplementedError
    end

    # :nocov:
  end
end
