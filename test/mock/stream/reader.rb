# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

require "adsp/stream/reader"

require_relative "raw/decompressor"

module ADSP
  module Test
    module Mock
      module Stream
        class Reader < ADSP::Stream::Reader
          RawDecompressor = Mock::Stream::Raw::Decompressor
        end
      end
    end
  end
end
