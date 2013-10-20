# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "churn/version"

Gem::Specification.new do |s|
  s.name = "churn"
  s.version = Churn::VERSION

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Dan Mayer"]
  s.date = "2012-12-17"
  s.summary = "Providing additional churn metrics over the original metric_fu churn"
  s.description = "High method and class churn has been shown to have increased bug and error rates. This gem helps you know what is changing a lot so you can do additional testing, code review, or refactoring to try to tame the volatile code. "
  s.email = "dan@mayerdan.com"
  s.homepage = "http://github.com/danmayer/churn"
  s.rubyforge_project = "churn"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.license = 'MIT'
  s.extra_rdoc_files = [
    "LICENSE",
    "README.md"
  ]

  s.add_development_dependency(%q<shoulda>, [">= 0"])
  s.add_development_dependency(%q<test-construct>, [">= 0"])
  s.add_development_dependency(%q<rake>, [">= 0"])
  s.add_development_dependency(%q<mocha>, ["~> 0.9.5"])
  s.add_development_dependency(%q<simplecov>,[">= 0"])
  s.add_development_dependency(%q<rdoc>,[">= 0"])
  #s.add_development_dependency(%q<ruby-debug>, ["~> 0.10.4"])
  s.add_runtime_dependency(%q<main>, [">= 0"])
  s.add_runtime_dependency(%q<json_pure>, [">= 0"])
  s.add_runtime_dependency(%q<chronic>, [">= 0.2.3"])
  s.add_runtime_dependency(%q<sexp_processor>, ["~> 4.1"])
  s.add_runtime_dependency(%q<ruby_parser>, ["~> 3.0"])
  s.add_runtime_dependency(%q<hirb>, [">= 0"])
  s.add_runtime_dependency(%q<rest-client>, [">= 1.6.0"])
end
