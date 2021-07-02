# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

require_relative "byte"
require_relative "char"
require_relative "codepoint"
require_relative "line"
require_relative "read"

module ADSP
  module Stream
    class Reader
      include Byte
      include Char
      include Codepoint
      include Line
      include Read

      module ClassMethods
        def open(file_path, *args, &block)
          Validation.validate_string file_path
          Validation.validate_proc block

          ::File.open file_path, "rb" do |io|
            reader = new io, *args

            begin
              yield reader
            ensure
              reader.close
            end
          end
        end
      end

      def self.included(klass)
        klass.extend ClassMethods
      end
    end
  end
end
