# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

Gem::Specification.new do |s|
  s.name                      = "zzsharedlib"
  s.version                   = "0.0.1"
  s.platform                  = Gem::Platform::RUBY
  s.required_ruby_version     = '>= 1.8'
  s.required_rubygems_version = ">= 1.3"
  s.authors                   = ["Greg Seitz"]
  s.summary                   = "ZangZing Utility library"
  s.description               = "Useful utility library"
  

  s.files        = Dir.glob("{lib,zzsharedlib}/**/*") + %w(Rakefile LICENSE README.rdoc)
  s.test_files = [
  ]
  
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ['lib','lib/zzsharedlib']
end