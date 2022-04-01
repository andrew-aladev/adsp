# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

module ADSP
  module Test
    module Common
      def self.flip_bytes(data)
        data.unpack("C").map { |byte| byte ^ 0xFF }.pack "C"
      end
    end
  end
end
