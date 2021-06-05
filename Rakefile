require "rake/testtask"
require "rubygems/package_task"

load "adsp.gemspec"

Rake::TestTask.new do |task|
  task.libs << %w[lib]

  pathes          = `find test | grep "\.test\.rb$"`
  task.test_files = ["test/coverage.rb"] + pathes.split("\n")
end

task :default => %i[test]

Gem::PackageTask.new(GEMSPEC).define
