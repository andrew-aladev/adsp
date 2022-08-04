# Abstract data stream processor.
# Copyright (c) 2021 AUTHORS, MIT License.

lib_path = File.expand_path "lib", __dir__
$LOAD_PATH.unshift lib_path unless $LOAD_PATH.include? lib_path

require "adsp/version"

GEMSPEC = Gem::Specification.new do |gem|
  gem.name     = "adsp"
  gem.summary  = "Abstract data stream processor."
  gem.homepage = "https://github.com/andrew-aladev/adsp"
  gem.license  = "MIT"
  gem.authors  = File.read("AUTHORS").split("\n").reject(&:empty?)
  gem.email    = "aladjev.andrew@gmail.com"
  gem.version  = ADSP::VERSION
  gem.metadata = {
    "rubygems_mfa_required" => "true"
  }

  gem.add_development_dependency "codecov"
  gem.add_development_dependency "json"
  gem.add_development_dependency "minitar", "~> 0.9"
  gem.add_development_dependency "minitest", "~> 5.16"
  gem.add_development_dependency "ocg", "~> 1.4"
  gem.add_development_dependency "parallel"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "rdoc"
  gem.add_development_dependency "rubocop", "~> 1.33"
  gem.add_development_dependency "rubocop-minitest", "~> 0.21"
  gem.add_development_dependency "rubocop-performance", "~> 1.14"
  gem.add_development_dependency "rubocop-rake", "~> 0.6"
  gem.add_development_dependency "simplecov"

  gem.files =
    `find lib test -type f -name "*.rb" -print0`.split("\x0") +
    %w[AUTHORS LICENSE README.md]
  gem.require_paths = %w[lib]

  gem.required_ruby_version = ">= 2.6"
end
