# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

require "adsp/string"

require_relative "common"
require_relative "minitest"
require_relative "mock/string"
require_relative "option"
require_relative "validation"

module ADSP
  # ADSP::Test module.
  module Test
    # ADSP::Test::String class.
    class String < Minitest::Test
      Option = Test::Option
      Target = Mock::String

      TEXTS       = Common::TEXTS
      LARGE_TEXTS = Common::LARGE_TEXTS

      BUFFER_LENGTH_NAMES   = %i[destination_buffer_length].freeze
      BUFFER_LENGTH_MAPPING = { :destination_buffer_length => :destination_buffer_length }.freeze

      def test_invalid_arguments
        Validation::INVALID_STRINGS.each do |invalid_string|
          assert_raises ValidateError do
            Target.compress invalid_string
          end

          assert_raises ValidateError do
            Target.decompress invalid_string
          end
        end

        get_invalid_compressor_options do |invalid_options|
          assert_raises ValidateError do
            Target.compress "", invalid_options
          end
        end

        get_invalid_decompressor_options do |invalid_options|
          assert_raises ValidateError do
            Target.decompress "", invalid_options
          end
        end
      end

      def test_texts
        parallel_compressor_options do |compressor_options|
          TEXTS.each do |text|
            compressed_text = Target.compress text, compressor_options

            get_compatible_decompressor_options compressor_options do |decompressor_options|
              decompressed_text = Target.decompress compressed_text, decompressor_options
              decompressed_text.force_encoding text.encoding

              assert_equal text, decompressed_text
            end
          end
        end
      end

      def test_large_texts
        Common.parallel LARGE_TEXTS do |text|
          compressed_text = Target.compress text

          decompressed_text = Target.decompress compressed_text
          decompressed_text.force_encoding text.encoding

          assert_equal text, decompressed_text
        end
      end

      # -----

      def get_invalid_compressor_options(&block)
        self.class::Option.get_invalid_compressor_options BUFFER_LENGTH_NAMES, &block
      end

      def get_invalid_decompressor_options(&block)
        self.class::Option.get_invalid_decompressor_options BUFFER_LENGTH_NAMES, &block
      end

      def parallel_compressor_options(&block)
        Common.parallel_options self.class::Option.get_compressor_options_generator(BUFFER_LENGTH_NAMES), &block
      end

      def get_compatible_decompressor_options(compressor_options, &block)
        self.class::Option.get_compatible_decompressor_options compressor_options, BUFFER_LENGTH_MAPPING, &block
      end
    end

    Minitest << String
  end
end
