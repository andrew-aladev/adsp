# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

require_relative "error"
require_relative "option"
require_relative "validation"

module ADSP
  class String
    Option = ADSP::Option

    BUFFER_LENGTH_NAMES = %i[destination_buffer_length].freeze

    def self.compress(source, options = {})
      Validation.validate_string source

      options = self::Option.get_compressor_options options, self::BUFFER_LENGTH_NAMES

      native_compress_string source, options
    end

    # :nocov:
    def self.native_compress_string(source, options)
      raise NotImplementedError
    end
    # :nocov:

    def self.decompress(source, options = {})
      Validation.validate_string source

      options = self::Option.get_decompressor_options options, self::BUFFER_LENGTH_NAMES

      native_decompress_string source, options
    end

    # :nocov:
    def self.native_decompress_string(source, options)
      raise NotImplementedError
    end
    # :nocov:
  end
end
