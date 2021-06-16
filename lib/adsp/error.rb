# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

module ADSP
  class BaseError < ::StandardError; end

  class NotImplementedError < BaseError; end
  class ValidateError       < BaseError; end
end
