# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

require "adsp"

require_relative "minitest"

module ADSP
  module Test
    class Version < Minitest::Test
      def test_versions
        refute_nil ADSP::VERSION
      end
    end

    Minitest << Version
  end
end
