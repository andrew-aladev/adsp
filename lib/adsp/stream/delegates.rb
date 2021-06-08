# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

require "forwardable"

module ADSP
  module Stream
    module Delegates
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

      def self.included(klass)
        klass.extend ::Forwardable
        klass.def_delegators :@io, *DELEGATES
      end
    end
  end
end

# close_read
# close_write
# pread
# pwrite
# reopen
# set_encoding_by_bom
# sysread
# sysseek
# syswrite
