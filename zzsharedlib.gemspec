# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

Gem::Specification.new do |s|
  s.name                      = "zzsharedlib"
  s.version                   = "0.0.7"
  s.platform                  = Gem::Platform::RUBY
  s.required_ruby_version     = '>= 1.8'
  s.required_rubygems_version = ">= 1.3"
  s.authors                   = ["Greg Seitz"]
  s.summary                   = "ZangZing Utility library"
  s.description               = "Useful utility library"
  

  s.add_dependency "right_aws", "< 3.0.0"
  s.add_dependency "json", ">= 1.4.4", "<= 1.5.2"

  s.files        = Dir.glob("{lib}/**/*") + %w(Rakefile LICENSE README.rdoc)
  s.test_files = [
  ]
  
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ['lib','lib/zzsharedlib']
end