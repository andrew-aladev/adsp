# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

module ADSP
  class BaseError < ::StandardError; end

  class NotEnoughDestinationError < BaseError; end
  class UnexpectedError           < BaseError; end
  class UsedAfterCloseError       < BaseError; end
  class ValidateError             < BaseError; end
end
