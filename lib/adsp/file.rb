# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

require_relative "error"
require_relative "option"
require_relative "validation"

module ADSP
  class File
    Option = ADSP::Option

    BUFFER_LENGTH_NAMES = %i[source_buffer_length destination_buffer_length].freeze

    def self.compress(source, destination, options = {})
      Validation.validate_string source
      Validation.validate_string destination

      options = self::Option.get_compressor_options options, self::BUFFER_LENGTH_NAMES

      open_files source, destination do |source_io, destination_io|
        native_compress_io source_io, destination_io, options
      end

      nil
    end

    # :nocov:
    def self.native_compress_io(source_io, destination_io, options)
      raise NotImplementedError
    end
    # :nocov:

    def self.decompress(source, destination, options = {})
      Validation.validate_string source
      Validation.validate_string destination

      options = self::Option.get_decompressor_options options, self::BUFFER_LENGTH_NAMES

      open_files source, destination do |source_io, destination_io|
        native_decompress_io source_io, destination_io, options
      end

      nil
    end

    # :nocov:
    def self.native_decompress_io(source_io, destination_io, options)
      raise NotImplementedError
    end
    # :nocov:

    private_class_method def self.open_files(source, destination, &_block)
      ::File.open source, "rb" do |source_io|
        ::File.open destination, "wb" do |destination_io|
          yield source_io, destination_io
        end
      end
    end
  end
end
