# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

if ENV["CI"]
  require "codecov"
  require "simplecov"

  SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new(
    [
      SimpleCov::Formatter::HTMLFormatter,
      SimpleCov::Formatter::Codecov
    ]
  )

  SimpleCov.start do
    add_filter %r{^/lib/adsp/test/}
    add_filter %r{^/test/}
  end
end
