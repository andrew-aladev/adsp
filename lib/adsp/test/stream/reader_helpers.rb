# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

require "English"
require "stringio"

require_relative "../common"
require_relative "../minitest"
require_relative "../option"
require_relative "../validation"
require_relative "../mock/stream/reader"
require_relative "../mock/string"

module ADSP
  module Test
    # ADSP::Test::Stream module.
    module Stream
      # ADSP::Test::Stream::ReaderHelpers class.
      class ReaderHelpers < Minitest::Test
        Target = Mock::Stream::Reader
        Option = Test::Option
        String = Mock::String

        ARCHIVE_PATH      = Common::ARCHIVE_PATH
        ENCODINGS         = Common::ENCODINGS
        TRANSCODE_OPTIONS = Common::TRANSCODE_OPTIONS
        TEXTS             = Common::TEXTS
        LARGE_TEXTS       = Common::LARGE_TEXTS

        BUFFER_LENGTH_NAMES   = %i[source_buffer_length destination_buffer_length].freeze
        BUFFER_LENGTH_MAPPING = {
          :source_buffer_length      => :destination_buffer_length,
          :destination_buffer_length => :source_buffer_length
        }
        .freeze

        LIMITS = [nil, 1].freeze

        def test_invalid_ungetbyte
          instance = target.new ::StringIO.new

          Validation::INVALID_STRINGS.each do |invalid_string|
            assert_raises ValidateError do
              instance.ungetbyte invalid_string
            end
          end
        end

        def test_byte
          parallel_compressor_options do |compressor_options, worker_index|
            archive_path = Common.get_path ARCHIVE_PATH, worker_index

            TEXTS.each do |text|
              write_archive archive_path, text, compressor_options

              get_compatible_decompressor_options compressor_options do |decompressor_options|
                target.open archive_path, decompressor_options do |instance|
                  # getbyte

                  byte = instance.getbyte
                  instance.ungetbyte byte unless byte.nil?

                  # readbyte

                  begin
                    byte = instance.readbyte
                    instance.ungetc byte
                  rescue ::EOFError
                    # ok
                  end

                  # each_byte

                  decompressed_text = "".b
                  instance.each_byte { |current_byte| decompressed_text << current_byte }

                  decompressed_text.force_encoding text.encoding
                  assert_equal text, decompressed_text
                end
              end
            end
          end
        end

        # -- char --

        def test_invalid_ungetc
          instance = target.new ::StringIO.new

          Validation::INVALID_STRINGS.each do |invalid_string|
            assert_raises ValidateError do
              instance.ungetc invalid_string
            end
          end
        end

        def test_char
          parallel_compressor_options do |compressor_options, worker_index|
            archive_path = Common.get_path ARCHIVE_PATH, worker_index

            TEXTS.each do |text|
              write_archive archive_path, text, compressor_options

              get_compatible_decompressor_options compressor_options do |decompressor_options|
                target.open archive_path, decompressor_options do |instance|
                  # getc

                  char = instance.getc
                  instance.ungetc char unless char.nil?

                  # readchar

                  begin
                    char = instance.readchar
                    instance.ungetc char
                  rescue ::EOFError
                    # ok
                  end

                  # each_char

                  decompressed_text = "".b
                  instance.each_char { |current_char| decompressed_text << current_char }

                  decompressed_text.force_encoding text.encoding
                  assert_equal text, decompressed_text
                end
              end
            end
          end
        end

        def test_char_encoding
          parallel_compressor_options do |compressor_options, worker_index|
            archive_path = Common.get_path ARCHIVE_PATH, worker_index

            TEXTS.each do |text|
              write_archive archive_path, text, compressor_options

              external_encoding = text.encoding

              (ENCODINGS - [external_encoding]).each do |internal_encoding|
                target_text = text.encode internal_encoding, **TRANSCODE_OPTIONS

                get_compatible_decompressor_options compressor_options do |decompressor_options|
                  target.open archive_path, decompressor_options do |instance|
                    instance.set_encoding external_encoding, internal_encoding, TRANSCODE_OPTIONS

                    # getc

                    char = instance.getc

                    unless char.nil?
                      assert_equal internal_encoding, char.encoding
                      instance.ungetc char
                    end

                    # readchar

                    begin
                      char = instance.readchar
                      assert_equal internal_encoding, char.encoding

                      instance.ungetc char
                    rescue ::EOFError
                      # ok
                    end

                    # each_char

                    decompressed_text = ::String.new :encoding => internal_encoding

                    instance.each_char do |current_char|
                      assert_equal internal_encoding, current_char.encoding
                      decompressed_text << current_char
                    end

                    assert_equal target_text, decompressed_text
                  end
                end
              end
            end
          end
        end

        # -- lines --

        def test_invalid_gets
          instance = target.new ::StringIO.new

          (Validation::INVALID_STRINGS - [nil, 1, 1.1]).each do |invalid_string|
            assert_raises ValidateError do
              instance.gets invalid_string
            end
          end

          (Validation::INVALID_POSITIVE_INTEGERS - [nil]).each do |invalid_integer|
            assert_raises ValidateError do
              instance.gets nil, invalid_integer
            end
          end
        end

        def test_invalid_ungetline
          instance = target.new ::StringIO.new

          Validation::INVALID_STRINGS.each do |invalid_string|
            assert_raises ValidateError do
              instance.ungetline invalid_string
            end
          end
        end

        def test_lines
          parallel_compressor_options do |compressor_options, worker_index|
            archive_path = Common.get_path ARCHIVE_PATH, worker_index

            TEXTS.each do |text|
              write_archive archive_path, text, compressor_options

              separator =
                if text.empty?
                  nil
                else
                  text[0]
                end

              get_compatible_decompressor_options compressor_options do |decompressor_options|
                target.open archive_path, decompressor_options do |instance|
                  # lineno

                  assert_equal 0, instance.lineno

                  instance.lineno = 1
                  assert_equal 1, instance.lineno

                  instance.lineno = 0
                  assert_equal 0, instance.lineno

                  # gets

                  LIMITS.each do |limit|
                    line = instance.gets limit
                    next if line.nil?

                    assert_equal 1, instance.lineno

                    instance.ungetline line
                    assert_equal 0, instance.lineno

                    # Same test with separator.

                    line = instance.gets separator, limit
                    next if line.nil?

                    assert_equal 1, instance.lineno

                    instance.ungetline line
                    assert_equal 0, instance.lineno
                  end

                  # readline

                  begin
                    line = instance.readline
                    assert_equal 1, instance.lineno

                    instance.ungetline line
                    assert_equal 0, instance.lineno
                  rescue ::EOFError
                    # ok
                  end

                  # readlines

                  lines = instance.readlines
                  lines.each { |current_line| instance.ungetline current_line }

                  decompressed_text = lines.join
                  decompressed_text.force_encoding text.encoding

                  assert_equal text, decompressed_text

                  # each_line

                  decompressed_text = "".b
                  instance.each_line { |current_line| decompressed_text << current_line }

                  decompressed_text.force_encoding text.encoding
                  assert_equal text, decompressed_text
                end
              end
            end
          end
        end

        def test_lines_encoding
          parallel_compressor_options do |compressor_options, worker_index|
            archive_path = Common.get_path ARCHIVE_PATH, worker_index

            TEXTS.each do |text|
              write_archive archive_path, text, compressor_options

              external_encoding = text.encoding

              (ENCODINGS - [external_encoding]).each do |internal_encoding|
                target_text = text.encode internal_encoding, **TRANSCODE_OPTIONS

                separator =
                  if text.empty?
                    nil
                  else
                    text[0]
                  end

                get_compatible_decompressor_options compressor_options do |decompressor_options|
                  target.open archive_path, decompressor_options do |instance|
                    instance.set_encoding external_encoding, internal_encoding, TRANSCODE_OPTIONS

                    # gets

                    line = instance.gets separator

                    unless line.nil?
                      assert_equal internal_encoding, line.encoding
                      instance.ungetline line
                    end

                    # readline

                    begin
                      line = instance.readline
                      assert_equal internal_encoding, line.encoding

                      instance.ungetline line
                    rescue ::EOFError
                      # ok
                    end

                    # each_line

                    decompressed_text = ::String.new :encoding => internal_encoding

                    instance.each_line do |current_line|
                      assert_equal internal_encoding, current_line.encoding
                      decompressed_text << current_line
                    end

                    assert_equal target_text, decompressed_text
                  end
                end
              end
            end
          end
        end

        # -- etc --

        def test_invalid_open
          Validation::INVALID_STRINGS.each do |invalid_string|
            assert_raises ValidateError do
              target.open(invalid_string) {} # no-op
            end
          end

          # Proc is required.
          assert_raises ValidateError do
            target.open ARCHIVE_PATH
          end
        end

        def test_open
          parallel_compressor_options do |compressor_options, worker_index|
            archive_path = Common.get_path ARCHIVE_PATH, worker_index

            TEXTS.each do |text|
              write_archive archive_path, text, compressor_options

              get_compatible_decompressor_options compressor_options do |decompressor_options|
                decompressed_text = target.open archive_path, decompressor_options, &:read
                decompressed_text.force_encoding text.encoding

                assert_equal text, decompressed_text
              end
            end
          end
        end

        def test_open_with_large_texts
          Common.parallel LARGE_TEXTS do |text, worker_index|
            archive_path = Common.get_path ARCHIVE_PATH, worker_index
            write_archive archive_path, text

            decompressed_text = target.open archive_path, &:read
            decompressed_text.force_encoding text.encoding

            assert_equal text, decompressed_text
          end
        end

        # -----

        protected def write_archive(archive_path, text, compressor_options = {})
          compressed_text = string.compress text, compressor_options
          ::File.write archive_path, compressed_text, :mode => "wb"
        end

        def parallel_compressor_options(&block)
          Common.parallel_options option.get_compressor_options_generator(BUFFER_LENGTH_NAMES), &block
        end

        def get_compatible_decompressor_options(compressor_options, &block)
          option.get_compatible_decompressor_options compressor_options, BUFFER_LENGTH_MAPPING, &block
        end

        protected def target
          self.class::Target
        end

        protected def option
          self.class::Option
        end

        protected def string
          self.class::String
        end
      end
    end
  end
end
