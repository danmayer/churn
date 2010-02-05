require 'rubygems'
require 'rake'
require 'lib/tasks/churn_tasks'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "churn"
    gem.summary = %Q{Providing additional churn metrics over the original metric_fu churn}
    gem.description = %Q{High method and class churn has been shown to have increased bug and error rates. This gem helps you know what is changing a lot so you can do additional testing, code review, or refactoring to try to tame the volatile code. }
    gem.email = "dan@devver.net"
    gem.homepage = "http://github.com/danmayer/churn"
    gem.authors = ["Dan Mayer"]
    gem.add_development_dependency "thoughtbot-shoulda"
    gem.add_development_dependency "test-construct"
    gem.add_development_dependency "mocha", '~> 0.9.5'
    gem.add_dependency "main"
    gem.add_dependency "json_pure"
    gem.add_dependency "chronic", '~> 0.2.3'
    gem.add_dependency "sexp_processor", '~> 3.0.3'
    gem.add_dependency "ruby_parser", '~> 2.0.4'
    gem.add_dependency 'hirb'
    gem.executables = ['churn']
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

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

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION')
    version = File.read('VERSION')
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "churn #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
