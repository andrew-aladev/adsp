# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

require "stringio"

require_relative "abstract"
require_relative "../../common"
require_relative "../../mock/stream/raw/compressor"
require_relative "../../mock/string"
require_relative "../../option"
require_relative "../../validation"

module ADSP
  module Test
    module Stream
      # ADSP::Test::Stream::Raw module.
      module Raw
        # ADSP::Test::Stream::Raw::Compressor class.
        class Compressor < Abstract
          Target = Mock::Stream::Raw::Compressor
          Option = Test::Option
          String = Mock::String

          TEXTS                 = Common::TEXTS
          LARGE_TEXTS           = Common::LARGE_TEXTS
          PORTION_LENGTHS       = Common::PORTION_LENGTHS
          LARGE_PORTION_LENGTHS = Common::LARGE_PORTION_LENGTHS

          BUFFER_LENGTH_NAMES   = %i[destination_buffer_length].freeze
          BUFFER_LENGTH_MAPPING = { :destination_buffer_length => :destination_buffer_length }.freeze

          def test_invalid_initialize
            get_invalid_compressor_options do |invalid_options|
              assert_raises ValidateError do
                target.new invalid_options
              end
            end
          end

          def test_invalid_write
            compressor = target.new

            Validation::INVALID_STRINGS.each do |invalid_string|
              assert_raises ValidateError do
                compressor.write invalid_string, &NOOP_PROC
              end
            end

            assert_raises ValidateError do
              compressor.write ""
            end

            compressor.close(&NOOP_PROC)

            assert_raises UsedAfterCloseError do
              compressor.write "", &NOOP_PROC
            end
          end

          def test_texts
            parallel_compressor_options do |compressor_options|
              TEXTS.each do |text|
                PORTION_LENGTHS.each do |portion_length|
                  compressed_buffer = ::StringIO.new
                  compressed_buffer.set_encoding ::Encoding::BINARY

                  writer     = proc { |portion| compressed_buffer << portion }
                  compressor = target.new compressor_options

                  begin
                    source      = "".b
                    text_offset = 0
                    index       = 0

                    loop do
                      portion = text.byteslice text_offset, portion_length
                      break if portion.nil?

                      text_offset += portion_length
                      source << portion

                      bytes_written = compressor.write source, &writer
                      source        = source.byteslice bytes_written, source.bytesize - bytes_written

                      compressor.flush(&writer) if index.even?
                      index += 1
                    end

                  ensure
                    refute_predicate compressor, :closed?
                    compressor.close(&writer)
                    assert_predicate compressor, :closed?
                  end

                  compressed_text = compressed_buffer.string

                  get_compatible_decompressor_options compressor_options do |decompressor_options|
                    decompressed_text = string.decompress compressed_text, decompressor_options
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

              compressed_buffer = ::StringIO.new
              compressed_buffer.set_encoding ::Encoding::BINARY

              writer     = proc { |portion| compressed_buffer << portion }
              compressor = target.new

              begin
                source      = "".b
                text_offset = 0

                loop do
                  portion = text.byteslice text_offset, portion_length
                  break if portion.nil?

                  text_offset += portion_length
                  source << portion

                  bytes_written = compressor.write source, &writer
                  source        = source.byteslice bytes_written, source.bytesize - bytes_written
                end
              ensure
                compressor.close(&writer)
              end

              compressed_text = compressed_buffer.string

              decompressed_text = string.decompress compressed_text
              decompressed_text.force_encoding text.encoding

              assert_equal text, decompressed_text
            end
          end

          # -----

          def get_invalid_compressor_options(&block)
            option.get_invalid_compressor_options BUFFER_LENGTH_NAMES, &block
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
