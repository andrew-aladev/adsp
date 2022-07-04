# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

require "adsp"

require_relative "minitest"

module ADSP
  # ADSP::Test module.
  module Test
    # ADSP::Test::Version class.
    class Version < Minitest::Test
      def test_version
        refute_nil ADSP::VERSION
      end
    end
  end
end
