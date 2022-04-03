# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

require "ocg"
require "adsp/option"

require_relative "validation"

module ADSP
  module Test
    module Option
      private_class_method def self.get_common_invalid_options(buffer_length_names, &block)
        Validation::INVALID_HASHES.each(&block)

        buffer_length_names.each do |name|
          (Validation::INVALID_NOT_NEGATIVE_INTEGERS - [nil]).each do |invalid_integer|
            yield({ name => invalid_integer })
          end
        end
      end

      def self.get_invalid_compressor_options(buffer_length_names, &block)
        get_common_invalid_options buffer_length_names, &block
      end

      def self.get_invalid_decompressor_options(buffer_length_names, &block)
        get_common_invalid_options buffer_length_names, &block
      end

      # -----

      # "0" means default buffer length.
      BUFFER_LENGTHS = [
        0,
        1
      ]
      .freeze

      private_class_method def self.get_buffer_length_option_generator(buffer_length_names)
        OCG.new(
          buffer_length_names.to_h { |name| [name, BUFFER_LENGTHS] }
        )
      end

      def self.get_compressor_options_generator(buffer_length_names)
        get_buffer_length_option_generator buffer_length_names
      end

      def self.get_compatible_decompressor_options(compressor_options, buffer_length_name_mapping, &_block)
        decompressor_options = {}

        buffer_length_name_mapping.each do |compressor_name, decompressor_name|
          decompressor_options[decompressor_name] = compressor_options[compressor_name]
        end

        yield decompressor_options
      end
    end
  end
end
