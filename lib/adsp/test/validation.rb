# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

require "stringio"

module ADSP
  module Test
    # ADSP::Test::Validation module.
    module Validation
      NOOP_PROC = proc {} # no-op

      TYPES = [
        nil,
        1,
        1.1,
        "1",
        true,
        "a",
        :a,
        {},
        [],
        $stdout,
        ::StringIO,
        NOOP_PROC
      ]
      .freeze

      INVALID_INTEGERS = (TYPES - [1]).freeze
      INVALID_NUMBERS  = (TYPES - [1, 1.1]).freeze
      INVALID_BOOLS    = (TYPES - [true]).freeze
      INVALID_STRINGS  = (TYPES - %w[1 a]).freeze
      INVALID_SYMBOLS  = (TYPES - %i[a]).freeze
      INVALID_ARRAYS   = (TYPES - [[]]).freeze
      INVALID_HASHES   = (TYPES - [{}]).freeze
      INVALID_CHARS    = (INVALID_NUMBERS & INVALID_STRINGS).freeze

      INVALID_POSITIVE_INTEGERS     = (INVALID_INTEGERS + [0, -1]).freeze
      INVALID_NOT_NEGATIVE_INTEGERS = (INVALID_POSITIVE_INTEGERS - [0]).freeze

      INVALID_ENCODINGS = %w[
        ISO_8859_0
        UTF-15
        UTF-33
      ]
      .freeze

      # ADSP::Test::Validation::StringIOWithoutEOF class.
      class StringIOWithoutEOF < ::StringIO
        undef :eof?
      end

      # ADSP::Test::Validation::StringIOWithoutRead class.
      class StringIOWithoutRead < ::StringIO
        undef :read
      end

      # ADSP::Test::Validation::StringIOWithoutReadNonblock class.
      class StringIOWithoutReadNonblock < ::StringIO
        undef :read_nonblock
      end

      # ADSP::Test::Validation::StringIOWithoutReadpartial class.
      class StringIOWithoutReadpartial < ::StringIO
        undef :readpartial
      end

      # ADSP::Test::Validation::StringIOWithoutWrite class.
      class StringIOWithoutWrite < ::StringIO
        undef :write
      end

      # ADSP::Test::Validation::StringIOWithoutWriteNonblock class.
      class StringIOWithoutWriteNonblock < ::StringIO
        undef :write_nonblock
      end
    end
  end
end
