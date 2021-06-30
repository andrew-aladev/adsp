# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

require "English"

require_relative "char"

module ADSP
  module Stream
    class Reader
      module Line
        include Char

        attr_accessor :lineno

        def gets(separator = $OUTPUT_RECORD_SEPARATOR, limit = nil)
          # Limit can be a first argument.
          if separator.is_a? ::Numeric
            limit     = separator
            separator = $OUTPUT_RECORD_SEPARATOR
          end

          line_ending =
            if separator.nil?
              nil
            else
              Validation.validate_string separator
              ::String.new separator, :encoding => target_encoding
            end

          Validation.validate_positive_integer limit unless limit.nil?

          line = ::String.new :encoding => target_encoding

          loop do
            char = getc

            if char.nil?
              return nil if line.empty?

              break
            end

            line << char

            break if
              (!line_ending.nil? && line.end_with?(line_ending)) ||
              (!limit.nil? && line.length >= limit)
          end

          @lineno += 1

          line
        end

        def each_line(&block)
          each_data method(:gets), &block
        end

        alias each each_line
        alias lines each_line

        def readline
          read_data method(:gets)
        end

        def readlines
          lines = []
          each_line { |line| lines << line }

          lines
        end

        alias to_a readlines

        def ungetline(line)
          Validation.validate_string line

          unget_string line

          @lineno -= 1

          nil
        end
      end
    end
  end
end
