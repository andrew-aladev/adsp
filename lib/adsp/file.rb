# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

require_relative "validation"

module ADSP
  class File
    def self.compress(source, destination)
      Validation.validate_string source
      Validation.validate_string destination

      nil
    end

    def self.decompress(source, destination)
      Validation.validate_string source
      Validation.validate_string destination

      nil
    end

    def self.open_files(source, destination, &_block)
      ::File.open source, "rb" do |source_io|
        ::File.open destination, "wb" do |destination_io|
          yield source_io, destination_io
        end
      end
    end
  end
end
