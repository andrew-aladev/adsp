# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

require_relative "validation"

module ADSP
  class String
    def self.compress(source, options = {})
      Validation.validate_string source

      native_compress_string source, options
    end

    # :nocov:
    protected def native_compress_string(source, options)
      raise NotImplementedError
    end
    # :nocov:

    def self.decompress(source, options = {})
      Validation.validate_string source

      native_decompress_string source, options
    end

    # :nocov:
    protected def native_decompress_string(source, options)
      raise NotImplementedError
    end
    # :nocov:
  end
end
