# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "beefcake/version"

Gem::Specification.new do |s|
  s.name        = "beefcake"
  s.version     = Beefcake::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Blake Mizerany"]
  s.email       = ["blake.mizerany@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{A sane protobuf library for Ruby}
  s.description = %q{A sane protobuf library for Ruby}

  s.rubyforge_project = "beefcake"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
