# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

require "forwardable"

module ADSP
  module Stream
    module Delegates
      # List of methods to be forwarded for native stream.
      DELEGATES = %i[
        autoclose=
        autoclose?
        binmode
        binmode?
        close_on_exec=
        close_on_exec?
        fcntl
        fdatasync
        fileno
        fsync
        ioctl
        isatty
        pid
        sync
        sync=
        to_i
        tty?
      ]
      .freeze

      # Defines delegates for native stream after module included.
      def self.included(klass)
        klass.extend ::Forwardable
        klass.def_delegators :@io, *DELEGATES
      end
    end
  end
end
