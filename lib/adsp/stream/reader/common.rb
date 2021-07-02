# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

module ADSP
  module Stream
    class Reader
      module Common
        # -- helpers --

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

        # -- IO data --

        protected def reset_io_remainder
          @io_remainder = ::String.new :encoding => ::Encoding::BINARY
        end

        protected def reset_need_to_flush
          @need_to_flush = false
        end

        protected def append_io_data(io_data)
          io_portion    = @io_remainder + io_data
          bytes_read    = raw_wrapper :read, io_portion
          @io_remainder = io_portion.byteslice bytes_read, io_portion.bytesize - bytes_read

          # Even empty io data may require flush.
          @need_to_flush = true
        end

        protected def flush_io_data
          raw_wrapper :flush

          @need_to_flush = false
        end

        # -- buffer data --

        protected def empty?
          !@need_to_flush && @buffer.bytesize.zero?
        end

        protected def unget_string(string)
          string = ::String.new string, :encoding => @internal_encoding unless @internal_encoding.nil?
          string = transcode_to_external string unless @external_encoding.nil?

          string.force_encoding ::Encoding::BINARY
          @buffer.prepend string

          nil
        end

        protected def read_bytes_from_buffer(bytes_to_read, out_buffer)
          bytes_read = [@buffer.bytesize, bytes_to_read].min

          # Result uses buffer binary encoding.
          result   = @buffer.byteslice 0, bytes_read
          @buffer  = @buffer.byteslice bytes_read, @buffer.bytesize - bytes_read
          @pos    += bytes_read

          result = out_buffer.replace result unless out_buffer.nil?
          result
        end

        protected def read_buffer(out_buffer)
          result = @buffer
          reset_buffer
          @pos += result.bytesize

          result.force_encoding @external_encoding unless @external_encoding.nil?
          result = transcode_to_internal result

          result = out_buffer.replace result unless out_buffer.nil?
          result
        end

        # -- transcode data --

        protected def transcode_to_internal(data)
          data = data.encode @internal_encoding, **@transcode_options unless @internal_encoding.nil?
          data
        end

        # We should be able to return data back to buffer.
        # We won't use any transcode options because transcoded data should be backward compatible.
        protected def transcode_to_external(data)
          data = data.encode @external_encoding unless @external_encoding.nil?
          data
        end

        # -- raw stream --

        protected def raw_wrapper(method_name, *args)
          @raw_stream.send(method_name, *args) { |portion| @buffer << portion }
        end
      end
    end
  end
end
