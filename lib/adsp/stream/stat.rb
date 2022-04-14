# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

require "forwardable"

module ADSP
  module Stream
    class Stat
      # Libraries like minitar tries to access stat to know whether stream is seekable.
      # We need to mark stream as not directory, file, etc, because it is not seekable.

      extend ::Forwardable

      # List of methods returning false.
      METHODS_RETURNING_FALSE = %i[
        blockdev?
        chardev?
        directory?
        executable?
        executable_real?
        file?
        grpowned?
        owned?
        pipe?
        setgid?
        setuid?
        socket?
        sticky?
        symlink?
        zero?
      ]
      .freeze

      # List of methods to be forwarded for native stream status info.
      DELEGATES = %i[
        <=>
        atime
        birthtime
        blksize
        blocks
        ctime
        dev
        dev_major
        dev_minor
        ftype
        gid
        ino
        inspect
        mode
        mtime
        nlink
        rdev
        rdev_major
        rdev_minor
        readable?
        readable_real?
        size
        size?
        uid
        world_readable?
        world_writable?
        writable?
        writable_real?
      ]
      .freeze

      # Initializes status info based on native stream +stat+.
      def initialize(stat)
        @stat = stat
      end

      METHODS_RETURNING_FALSE.each do |method_name|
        define_method(method_name) { false }
      end

      def_delegators :@stat, *DELEGATES
    end
  end
end
