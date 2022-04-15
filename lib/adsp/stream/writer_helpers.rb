# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

require "English"

require_relative "../validation"

module ADSP
  module Stream
    module WriterHelpers
      # Writes +object+ to stream.
      def <<(object)
        write object
      end

      # Writes +objects+ to stream.
      # Uses +field_separator+ for each object.
      # Uses +record_separator+ for group of objects.
      def print(*objects, field_separator: $OUTPUT_FIELD_SEPARATOR, record_separator: $OUTPUT_RECORD_SEPARATOR)
        objects.each do |object|
          write object
          write field_separator unless field_separator.nil?
        end

        write record_separator unless record_separator.nil?

        nil
      end

      # Formats each argument and writes to stream.
      def printf(*args)
        write sprintf(*args)

        nil
      end

      # Writes first char of +object+ to stream.
      # Numeric object uses +encoding+ for providing first char.
      def putc(object, encoding: ::Encoding::BINARY)
        case object
        when ::Numeric
          write object.chr(encoding)
        when ::String
          write object[0]
        else
          raise ValidateError, "invalid object: \"#{object}\" for putc"
        end

        object
      end

      # Writes +objects+ to stream.
      def puts(*objects)
        objects.each do |object|
          if object.is_a? ::Array
            puts(*object)
            next
          end

          source  = object.to_s
          newline = "\n".encode source.encoding

          # Do not add newline if source ends with newline.
          if source.end_with? newline
            write source
          else
            write source + newline
          end
        end

        nil
      end

      # -- etc --

      # Additional class methods for writer.
      module ClassMethods
        # Opens +file_path+ in binary mode, creates writer and yields it.
        def open(file_path, *args, &block)
          Validation.validate_string file_path
          Validation.validate_proc block

          ::File.open file_path, "wb" do |io|
            writer = new io, *args

            begin
              yield writer
            ensure
              writer.close
            end
          end
        end
      end

      # Extends target +klass+ with additional class methods.
      def self.included(klass)
        klass.extend ClassMethods
      end
    end
  end
end
