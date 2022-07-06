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
    track_files "lib/*.rb"
    track_files "lib/adsp/*.rb"
    track_files "lib/adsp/stream/**/*.rb"
  end
end
