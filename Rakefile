require 'rake'
require 'rake/testtask'
require 'bundler/gem_tasks'
Bundler::GemHelper.install_tasks

Rake::TestTask.new do |t|
  t.libs << 'minitest'
  t.test_files = FileList['test/*_test.rb']
  t.verbose = true
end

task :default => :test