# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

require_relative "error"

module ADSP
  class Validation
    def self.validate_array(value)
      raise ValidateError, "invalid array" unless value.is_a? ::Array
    end

    def self.validate_hash(value)
      raise ValidateError, "invalid hash" unless value.is_a? ::Hash
    end

    def self.validate_not_negative_integer(value)
      raise ValidateError, "invalid not negative integer" unless value.is_a?(::Integer) && value >= 0
    end

    def self.validate_positive_integer(value)
      raise ValidateError, "invalid positive integer" unless value.is_a?(::Integer) && value.positive?
    end

    def self.validate_proc(value)
      unless value.is_a?(::Proc) || value.is_a?(::Method) || value.is_a?(::UnboundMethod)
        raise ValidateError, "invalid proc"
      end
    end

    def self.validate_string(value)
      raise ValidateError, "invalid string" unless value.is_a? ::String
    end

    def self.validate_symbol(value)
      raise ValidateError, "invalid symbol" unless value.is_a? ::Symbol
    end
  end
end
