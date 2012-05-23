require 'rubygems'
require 'rake'
require 'lib/tasks/churn_tasks'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "churn"
    gem.summary = %Q{Providing additional churn metrics over the original metric_fu churn}
    gem.description = %Q{High method and class churn has been shown to have increased bug and error rates. This gem helps you know what is changing a lot so you can do additional testing, code review, or refactoring to try to tame the volatile code. }
    gem.email = "dan@mayerdan.com"
    gem.homepage = "http://github.com/danmayer/churn"
    gem.authors = ["Dan Mayer"]
    gem.add_development_dependency "shoulda"
    gem.add_development_dependency "jeweler", '~> 1.6'
    gem.add_development_dependency "test-construct"
    gem.add_development_dependency "mocha", '~> 0.9.5'
    gem.add_dependency "main"
    gem.add_dependency "json_pure"
    gem.add_dependency "chronic", '>= 0.2.3'
    gem.add_dependency "sexp_processor", '~> 3.0'
    gem.add_dependency "ruby_parser", '~> 2.3'
    gem.add_dependency 'hirb'
    gem.executables = ['churn']
  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

begin
  #for additional metrics, mostly Rcov which caliper doesn't do
  require 'metric_fu'
  
  MetricFu::Configuration.run do |config|
    config.metrics  = [:churn, :saikuro, :roodi, :flog, :flay, :reek, :roodi, :rcov, :hotspots]
    config.graphs   = [:roodi, :flog, :flay, :reek, :roodi, :rcov]
    
    config.flay     = { :dirs_to_flay => ['lib']  } 
    config.flog     = { :dirs_to_flog => ['lib']  }
    config.reek     = { :dirs_to_reek => ['lib']  }
    config.roodi    = { :dirs_to_roodi => ['lib'] }
    config.saikuro  = { :output_directory => 'tmp/tmp_saikuro', 
      :input_directory => ['lib'],
      :cyclo => "",
      :filter_cyclo => "0",
      :warn_cyclo => "5",
      :error_cyclo => "7",
      :formater => "text"} #this needs to be set to "text"
    config.churn    = { :start_date => "3 months ago", :minimum_churn_count => 10}
    config.rcov     = { :test_files => ['test/unit/**/*_test.rb'],
      :rcov_opts => ["--sort coverage", 
                     "--no-html", 
                     "--text-coverage",
                     "--no-color",
                     "--profile",
                     "--exclude /gems/,spec"]}
  end
rescue Exception
  puts "metric_fu not working install it"
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
