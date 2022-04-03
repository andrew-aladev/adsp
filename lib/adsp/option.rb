# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

require_relative "validation"

module ADSP
  class Option
    DEFAULT_BUFFER_LENGTH = 0

    def self.get_compressor_options(options, buffer_length_names = [])
      Validation.validate_hash options
      Validation.validate_array buffer_length_names

      buffer_length_names.each { |name| Validation.validate_symbol name }

      buffer_length_defaults = buffer_length_names.each_with_object({}) do |name, defaults|
        defaults[name] = DEFAULT_BUFFER_LENGTH
      end

      options = buffer_length_defaults.merge options

      buffer_length_names.each { |name| Validation.validate_not_negative_integer options[name] }

      options
    end

    def self.get_decompressor_options(options, buffer_length_names = [])
      Validation.validate_hash options
      Validation.validate_array buffer_length_names

      buffer_length_names.each { |name| Validation.validate_symbol name }

      buffer_length_defaults = buffer_length_names.each_with_object({}) do |name, defaults|
        defaults[name] = DEFAULT_BUFFER_LENGTH
      end

      options = buffer_length_defaults.merge options

      buffer_length_names.each { |name| Validation.validate_not_negative_integer options[name] }

      options
    end
  end
end
