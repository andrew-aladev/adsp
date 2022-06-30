# Abstract data stream processor

| AppVeyor | Jenkins | Github actions | Codecov | Gem  |
| :------: | :-----: | :------------: | :-----: | :--: |
| [![AppVeyor test status](https://ci.appveyor.com/api/projects/status/github/andrew-aladev/adsp?branch=master&svg=true)](https://ci.appveyor.com/project/andrew-aladev/adsp/branch/master) | [![Jenkins test status](http://37.187.122.190:58182/buildStatus/icon?job=adsp)](http://37.187.122.190:58182/job/adsp) | [![Github Actions test status](https://github.com/andrew-aladev/adsp/workflows/test/badge.svg?branch=master)](https://github.com/andrew-aladev/adsp/actions) | [![Codecov](https://codecov.io/gh/andrew-aladev/adsp/branch/master/graph/badge.svg)](https://codecov.io/gh/andrew-aladev/adsp) | [![Gem](https://img.shields.io/gem/v/adsp.svg)](https://rubygems.org/gems/adsp) |

## Installation

Operating systems: GNU/Linux, FreeBSD, OSX.

## Usage

There are simple APIs: `String` and `File`. Also you can use generic streaming API: `Stream::Writer` and `Stream::Reader`.

```ruby
require "adsp"

data = ADSP::String.compress "sample string"
puts ADSP::String.decompress(data)

ADSP::File.compress "file.txt", "file.txt.archive"
ADSP::File.decompress "file.txt.archive", "file.txt"

ADSP::Stream::Writer.open("file.txt.archive") { |writer| writer << "sample string" }
puts ADSP::Stream::Reader.open("file.txt.archive") { |reader| reader.read }

writer = ADSP::Stream::Writer.new output_socket
begin
  bytes_written = writer.write_nonblock "sample string"
  # handle "bytes_written"
rescue IO::WaitWritable
  # handle wait
ensure
  writer.close
end

reader = ADSP::Stream::Reader.new input_socket
begin
  puts reader.read_nonblock(512)
rescue IO::WaitReadable
  # handle wait
rescue ::EOFError
  # handle eof
ensure
  reader.close
end
```

You can create and read `tar.archive` archives with [minitar](https://github.com/halostatue/minitar).

```ruby
require "adsp"
require "minitar"

ADSP::Stream::Writer.open "file.tar.archive" do |writer|
  Minitar::Writer.open writer do |tar|
    tar.add_file_simple "file", :data => "sample string"
  end
end

ADSP::Stream::Reader.open "file.tar.archive" do |reader|
  Minitar::Reader.open reader do |tar|
    tar.each_entry do |entry|
      puts entry.name
      puts entry.read
    end
  end
end
```

All functionality (including streaming) can be used inside multiple threads with [parallel](https://github.com/grosser/parallel).
This code will provide heavy load for your CPU.

```ruby
require "adsp"
require "parallel"

Parallel.each large_datas do |large_data|
  ADSP::String.compress large_data
end
```

# Docs

Please review [rdoc generated docs](https://andrew-aladev.github.io/adsp).

## Options

| Option                          | Values         | Default    | Description |
|---------------------------------|----------------|------------|-------------|
| `source_buffer_length`          | 0 - inf        | 0 (auto)   | internal buffer length for source data |
| `destination_buffer_length`     | 0 - inf        | 0 (auto)   | internal buffer length for description data |

There are internal buffers for compressed and decompressed data.
For example you want to use 1 KB as `source_buffer_length` for compressor - please use 256 B as `destination_buffer_length`.
You want to use 256 B as `source_buffer_length` for decompressor - please use 1 KB as `destination_buffer_length`.

Possible compressor options:
```
:source_buffer_length
:destination_buffer_length
```

Possible decompressor options:
```
:source_buffer_length
:destination_buffer_length
```

Example:

```ruby
require "adsp"

data = ADSP::String.compress "sample string", :source_buffer_length => 512
puts ADSP::String.decompress(data, :source_buffer_length => 512)
```

## String

String maintains destination buffer only, so it accepts `destination_buffer_length` option only.

```
::compress(source, options = {})
::decompress(source, options = {})
```

`source` is a source string.

## File

File maintains both source and destination buffers, it accepts both `source_buffer_length` and `destination_buffer_length` options.

```
::compress(source, destination, options = {})
::decompress(source, destination, options = {})
```

`source` and `destination` are file pathes.

## Stream::Writer

Its behaviour is similar to builtin [`Zlib::GzipWriter`](https://ruby-doc.org/stdlib/libdoc/zlib/rdoc/Zlib/GzipWriter.html).

Writer maintains destination buffer only, so it accepts `destination_buffer_length` option only.

```
::open(file_path, options = {}, :external_encoding => nil, :transcode_options => {}, &block)
```

Open file path and create stream writer associated with opened file.
Data will be transcoded to `:external_encoding` using `:transcode_options` before compressing.

It may be tricky to use both `:pledged_size` and `:transcode_options`. You have to provide size of transcoded input.

```
::new(destination_io, options = {}, :external_encoding => nil, :transcode_options => {})
```

Create stream writer associated with destination io.
Data will be transcoded to `:external_encoding` using `:transcode_options` before compressing.

It may be tricky to use both `:pledged_size` and `:transcode_options`. You have to provide size of transcoded input.

```
#set_encoding(external_encoding, nil, transcode_options)
```

Set another encodings, `nil` is just for compatibility with `IO`.

```
#io
#to_io
#stat
#external_encoding
#transcode_options
#pos
#tell
```

See [`IO`](https://ruby-doc.org/core/IO.html) docs.

```
#write(*objects)
#flush
#rewind
#close
#closed?
```

See [`Zlib::GzipWriter`](https://ruby-doc.org/stdlib/libdoc/zlib/rdoc/Zlib/GzipWriter.html) docs.

```
#write_nonblock(object, *options)
#flush_nonblock(*options)
#rewind_nonblock(*options)
#close_nonblock(*options)
```

Special asynchronous methods missing in `Zlib::GzipWriter`.
`rewind` wants to `close`, `close` wants to `write` something and `flush`, `flush` want to `write` something.
So it is possible to have asynchronous variants for these synchronous methods.
Behaviour is the same as `IO#write_nonblock` method.

```
#<<(object)
#print(*objects)
#printf(*args)
#putc(object, :encoding => 'ASCII-8BIT')
#puts(*objects)
```

Typical helpers, see [`Zlib::GzipWriter`](https://ruby-doc.org/stdlib/libdoc/zlib/rdoc/Zlib/GzipWriter.html) docs.

## Stream::Reader

Its behaviour is similar to builtin [`Zlib::GzipReader`](https://ruby-doc.org/stdlib/libdoc/zlib/rdoc/Zlib/GzipReader.html).

Reader maintains both source and destination buffers, it accepts both `source_buffer_length` and `destination_buffer_length` options.

```
::open(file_path, options = {}, :external_encoding => nil, :internal_encoding => nil, :transcode_options => {}, &block)
```

Open file path and create stream reader associated with opened file.
Data will be force encoded to `:external_encoding` and transcoded to `:internal_encoding` using `:transcode_options` after decompressing.

```
::new(source_io, options = {}, :external_encoding => nil, :internal_encoding => nil, :transcode_options => {})
```

Create stream reader associated with source io.
Data will be force encoded to `:external_encoding` and transcoded to `:internal_encoding` using `:transcode_options` after decompressing.

```
#set_encoding(external_encoding, internal_encoding, transcode_options)
```

Set another encodings.

```
#io
#to_io
#stat
#external_encoding
#internal_encoding
#transcode_options
#pos
#tell
```

See [`IO`](https://ruby-doc.org/core/IO.html) docs.

```
#read(bytes_to_read = nil, out_buffer = nil)
#eof?
#rewind
#close
#closed?
```

See [`Zlib::GzipReader`](https://ruby-doc.org/stdlib/libdoc/zlib/rdoc/Zlib/GzipReader.html) docs.

```
#readpartial(bytes_to_read = nil, out_buffer = nil)
#read_nonblock(bytes_to_read, out_buffer = nil, *options)
```

See [`IO`](https://ruby-doc.org/core/IO.html) docs.

```
#getbyte
#each_byte(&block)
#readbyte
#ungetbyte(byte)

#getc
#readchar
#each_char(&block)
#ungetc(char)

#lineno
#lineno=
#gets(separator = $OUTPUT_RECORD_SEPARATOR, limit = nil)
#readline
#readlines
#each(&block)
#each_line(&block)
#ungetline(line)
```

Typical helpers, see [`Zlib::GzipReader`](https://ruby-doc.org/stdlib/libdoc/zlib/rdoc/Zlib/GzipReader.html) docs.

## CI

Please visit [scripts/test-images](scripts/test-images).
See universal test script [scripts/ci_test.sh](scripts/ci_test.sh) for CI.

## License

MIT license, see [LICENSE](LICENSE) and [AUTHORS](AUTHORS).
