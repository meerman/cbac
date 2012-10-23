# Rakefile
require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'echoe'
require 'cbac/version'

# Setting default task
desc 'Default: run unit tests.'
task :default => :test

# Test task
#desc 'Test CBAC plugin.'
#Rake::TestTask.new(:test) do |t|
#  t.libs << 'lib'
#  t.pattern = 'test/**/test_*.rb'
#  t.verbose = true
#end

# Documentation task
desc 'Generate documentation for CBAC plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Cbac'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

# Echo information for packaging
Echoe.new('cbac', Cbac::VERSION) do |p|
  p.summary        = "CBAC - Simple authorization system for Rails applications."
  p.description    = "Simple authorization system for Rails applications. Allows you to develop applications with a mixed role based authorization and a context based authorization model. Does not supply authentication."
  p.url            = "http://cbac.rubyforge.org"
  p.author         = "Bert Meerman"
  p.email          = "bertm@rubyforge.org"
  p.ignore_pattern = []
  p.retain_gemspec = true
  p.development_dependencies = []
end
