# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

require "adsp/stream/raw/decompressor"

require_relative "native_decompressor"

module ADSP
  module Test
    module Mock
      module Stream
        module Raw
          class Decompressor < ADSP::Stream::Raw::Decompressor
            NativeDecompressor = Raw::NativeDecompressor
          end
        end
      end
    end
  end
end
