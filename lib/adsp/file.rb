# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

require_relative "validation"

module ADSP
  class File
    def self.compress(source, destination, options = {})
      Validation.validate_string source
      Validation.validate_string destination

      open_files source, destination do |source_io, destination_io|
        native_compress_io source_io, destination_io, options
      end

      nil
    end

    # :nocov:
    protected def native_compress_io(source_io, destination_io, options)
      raise NotImplementedError
    end
    # :nocov:

    def self.decompress(source, destination, options = {})
      Validation.validate_string source
      Validation.validate_string destination

      open_files source, destination do |source_io, destination_io|
        native_decompress_io source_io, destination_io, options
      end

      nil
    end

    # :nocov:
    protected def native_decompress_io(source_io, destination_io, options)
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
