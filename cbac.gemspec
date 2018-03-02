# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name    = "cbac"
  s.version = "0.7.0"

  s.authors                   = ["Bert Meerman"]
  s.date                      = "2016-08-15"
  s.description               = "Simple authorization system for Rails applications. Allows you to develop applications with a mixed role based authorization and a context based authorization model. Does not supply authentication."
  s.email                     = "bertm@rubyforge.org"
  s.files                     = `git ls-files`.split("\n")
  s.homepage                  = "http://cbac.rubyforge.org"
  s.license                   = "MIT"
  s.rdoc_options              = ["--line-numbers", "--inline-source", "--title", "Cbac", "--main", "README.rdoc"]
  s.require_paths             = ["lib"]
  s.required_ruby_version     = ">= 2.2.2"
  s.required_rubygems_version = ">= 1.8.11"
  s.rubyforge_project         = "cbac"
  s.summary                   = "CBAC - Simple authorization system for Rails applications."
  s.test_files                = `git ls-files -- test/*.*`.split("\n")

  s.add_development_dependency("database_cleaner", "~> 1.5")
  s.add_development_dependency("rspec-rails", "~> 3")
  s.add_development_dependency("sqlite3", "~> 1.3")
  s.add_runtime_dependency("echoe", "~> 4")
  s.add_runtime_dependency("rails", "~> 5.0")
end
