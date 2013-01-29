require 'rubygems'
require 'rake'
require File.join(File.dirname(__FILE__), 'lib', 'tasks', 'churn_tasks')

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/*_test.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :default => :test

desc "Build Gem"
task :build_gem do
  `gem build churn.gemspec`
  `mv churn*.gem pkg/`
end

require 'rdoc/task'
$:.push File.expand_path("../lib", __FILE__)
require "churn/version"
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "churn #{Churn::VERSION}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
