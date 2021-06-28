# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

module ADSP
  module Stream
    module ReaderHelpers
      module Common
        protected def each_data(each_proc, &block)
          return enum_for __method__, each_proc unless block.is_a? ::Proc

          loop do
            data = each_proc.call
            break if data.nil?

            yield data
          end

          nil
        end

        protected def read_data(each_proc)
          data = each_proc.call
          raise ::EOFError if data.nil?

          data
        end

        protected def unget_string(string)
          string = ::String.new string, :encoding => @internal_encoding unless @internal_encoding.nil?
          string = transcode_to_external string unless @external_encoding.nil?

          string.force_encoding ::Encoding::BINARY
          @buffer.prepend string

          nil
        end
      end
    end
  end
end
