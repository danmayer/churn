# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "churn/version"

Gem::Specification.new do |s|
  s.name = "churn"
  s.version = Churn::VERSION

  s.author = "Dan Mayer"
  s.summary = "Providing additional churn metrics over the original metric_fu churn"
  s.description = "High method and class churn has been shown to have increased bug and error rates. This gem helps you know what is changing a lot so you can do additional testing, code review, or refactoring to try to tame the volatile code. "
  s.email = "dan@mayerdan.com"
  s.homepage = "http://github.com/danmayer/churn"

  s.executables = %w[churn]

  s.files = %w[churn.gemspec LICENSE.txt README.md] + Dir["bin/*", "lib/**/*.rb", "man/*"]
  s.license = "MIT"
  s.require_paths = %w[lib]
  s.required_ruby_version = ">= 1.9.3"
  s.requirements = "bzr, git, hg or svn"

  s.add_runtime_dependency "main", ">= 0"
  # TODO: How to replace chronic, or just have less verbose time support
  s.add_runtime_dependency "chronic", ">= 0.2.3"
  s.add_runtime_dependency "sexp_processor", "~> 4.17"
  s.add_runtime_dependency "ruby_parser", "~> 3.0"
  # TODO: Just have clean output and drop hirb
  s.add_runtime_dependency "hirb", ">= 0"

  s.add_development_dependency 'pry-byebug'
  s.add_development_dependency "minitest", "~> 5.22"
  s.add_development_dependency "test_construct", "~> 2.0.0"
  s.add_development_dependency "rake", ">= 0"
  s.add_development_dependency "mocha", "~> 2.1.0"
  s.add_development_dependency "simplecov", ">= 0"
  s.add_development_dependency "yard", "~> 0.9.20"
  # NOTE: we haven't been updating the man file, and ronn was used to do that... clean up
  # s.add_development_dependency "ronn"
  # s.add_development_dependency "kramdown", platform: :jruby
  s.add_development_dependency "redcarpet"
end
