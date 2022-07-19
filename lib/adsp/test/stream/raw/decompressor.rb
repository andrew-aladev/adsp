# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

require "stringio"

require_relative "abstract"
require_relative "../../common"
require_relative "../../mock/stream/raw/decompressor"
require_relative "../../mock/string"
require_relative "../../option"
require_relative "../../validation"

module ADSP
  module Test
    module Stream
      # ADSP::Test::Stream::Raw module.
      module Raw
        # ADSP::Test::Stream::Raw::Decompressor class.
        class Decompressor < Abstract
          Target = Mock::Stream::Raw::Decompressor
          Option = Test::Option
          String = Mock::String

          TEXTS                 = Common::TEXTS
          LARGE_TEXTS           = Common::LARGE_TEXTS
          PORTION_LENGTHS       = Common::PORTION_LENGTHS
          LARGE_PORTION_LENGTHS = Common::LARGE_PORTION_LENGTHS

          BUFFER_LENGTH_NAMES   = %i[destination_buffer_length].freeze
          BUFFER_LENGTH_MAPPING = { :destination_buffer_length => :destination_buffer_length }.freeze

          def test_invalid_initialize
            get_invalid_decompressor_options do |invalid_options|
              assert_raises ValidateError do
                target.new invalid_options
              end
            end
          end

          def test_invalid_read
            decompressor = target.new

            Validation::INVALID_STRINGS.each do |invalid_string|
              assert_raises ValidateError do
                decompressor.read invalid_string, &NOOP_PROC
              end
            end

            assert_raises ValidateError do
              decompressor.read ""
            end

            decompressor.close(&NOOP_PROC)

            assert_raises UsedAfterCloseError do
              decompressor.read "", &NOOP_PROC
            end
          end

          def test_texts
            parallel_compressor_options do |compressor_options|
              TEXTS.each do |text|
                compressed_text = string.compress text, compressor_options

                PORTION_LENGTHS.each do |portion_length|
                  get_compatible_decompressor_options compressor_options do |decompressor_options|
                    decompressed_buffer = ::StringIO.new
                    decompressed_buffer.set_encoding ::Encoding::BINARY

                    writer       = proc { |portion| decompressed_buffer << portion }
                    decompressor = target.new decompressor_options

                    begin
                      source                 = "".b
                      compressed_text_offset = 0
                      index                  = 0

                      loop do
                        portion = compressed_text.byteslice compressed_text_offset, portion_length
                        break if portion.nil?

                        compressed_text_offset += portion_length
                        source << portion

                        bytes_read = decompressor.read source, &writer
                        source     = source.byteslice bytes_read, source.bytesize - bytes_read

                        decompressor.flush(&writer) if index.even?
                        index += 1
                      end

                    ensure
                      refute_predicate decompressor, :closed?
                      decompressor.close(&writer)
                      assert_predicate decompressor, :closed?
                    end

                    decompressed_text = decompressed_buffer.string
                    decompressed_text.force_encoding text.encoding

                    assert_equal text, decompressed_text
                  end
                end
              end
            end
          end

          def test_large_texts
            options_generator = OCG.new(
              :text           => LARGE_TEXTS,
              :portion_length => LARGE_PORTION_LENGTHS
            )

            Common.parallel_options options_generator do |options|
              text           = options[:text]
              portion_length = options[:portion_length]

              compressed_text = string.compress text

              decompressed_buffer = ::StringIO.new
              decompressed_buffer.set_encoding ::Encoding::BINARY

              writer       = proc { |portion| decompressed_buffer << portion }
              decompressor = target.new

              begin
                source                 = "".b
                compressed_text_offset = 0

                loop do
                  portion = compressed_text.byteslice compressed_text_offset, portion_length
                  break if portion.nil?

                  compressed_text_offset += portion_length
                  source << portion

                  bytes_read = decompressor.read source, &writer
                  source     = source.byteslice bytes_read, source.bytesize - bytes_read
                end
              ensure
                decompressor.close(&writer)
              end

              decompressed_text = decompressed_buffer.string
              decompressed_text.force_encoding text.encoding

              assert_equal text, decompressed_text
            end
          end

          # -----

          def get_invalid_decompressor_options(&block)
            option.get_invalid_decompressor_options BUFFER_LENGTH_NAMES, &block
          end

          def parallel_compressor_options(&block)
            Common.parallel_options option.get_compressor_options_generator(BUFFER_LENGTH_NAMES), &block
          end

          def get_compatible_decompressor_options(compressor_options, &block)
            option.get_compatible_decompressor_options compressor_options, BUFFER_LENGTH_MAPPING, &block
          end

          def option
            self.class::Option
          end

          def string
            self.class::String
          end
        end
      end
    end
  end
end
