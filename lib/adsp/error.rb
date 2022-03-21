# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

module ADSP
  class BaseError < ::StandardError; end

  class ValidateError < BaseError; end

  class NotImplementedError < BaseError; end
  class UnexpectedError     < BaseError; end
end
