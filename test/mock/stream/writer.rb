# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

require "adsp/stream/writer"

require_relative "raw/compressor"

module ADSP
  module Test
    module Mock
      module Stream
        class Writer < ADSP::Stream::Writer
          RawCompressor = Mock::Stream::Raw::Compressor
        end
      end
    end
  end
end
