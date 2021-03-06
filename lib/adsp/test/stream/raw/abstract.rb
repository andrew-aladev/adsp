# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

require_relative "../../minitest"
require_relative "../../validation"

module ADSP
  module Test
    module Stream
      module Raw
        # ADSP::Test::Stream::Raw::Abstract class.
        class Abstract < Minitest::Test
          NOOP_PROC = Validation::NOOP_PROC

          def test_invalid_flush
            instance = target.new

            assert_raises ValidateError do
              instance.flush
            end

            instance.close(&NOOP_PROC)

            assert_raises UsedAfterCloseError do
              instance.flush(&NOOP_PROC)
            end
          end

          def test_invalid_close
            instance = target.new

            assert_raises ValidateError do
              instance.close
            end
          end

          # -----

          protected def target
            self.class::Target
          end
        end
      end
    end
  end
end
