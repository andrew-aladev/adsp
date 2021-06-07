# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

require_relative "validation"

module ADSP
  class String
    def self.compress(source)
      Validation.validate_string source

      nil
    end

    def self.decompress(source)
      Validation.validate_string source

      nil
    end
  end
end
