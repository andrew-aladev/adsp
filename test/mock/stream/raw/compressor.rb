# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

require "adsp/stream/raw/compressor"

require_relative "native_compressor"

module ADSP
  module Test
    module Mock
      module Stream
        module Raw
          class Compressor < ADSP::Stream::Raw::Compressor
            NativeCompressor = Raw::NativeCompressor
          end
        end
      end
    end
  end
end
