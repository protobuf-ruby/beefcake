# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "beefcake/version"

Gem::Specification.new do |s|
  s.name        = "beefcake"
  s.version     = Beefcake::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Blake Mizerany", "Matt Proud", "Bryce Kerley"]
  s.email       = ["blake.mizerany@gmail.com", "matt.proud@gmail.com", "bkerley@brycekerley.net"]
  s.homepage    = "https://github.com/protobuf-ruby/beefcake"
  s.summary     = %q{A sane protobuf library for Ruby}
  s.description = %q{A sane protobuf library for Ruby}
  s.license     = 'MIT'

  s.rubyforge_project = "beefcake"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency('rake', '10.1.0')
end
