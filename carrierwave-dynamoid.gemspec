# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "carrierwave/dynamoid/version"

Gem::Specification.new do |s|
  s.name        = "carrierwave-dynamoid"
  s.version     = Carrierwave::Dynamoid::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Nic Barthelemy"]
  s.email       = ["nbarthel@axomi.com"]
  s.homepage    = "https://github.com/axomi/carrierwave-dynamoid"
  s.summary     = %q{Dynamoid support for CarrierWave}
  s.description = %q{Dynamoid support for CarrierWave}

  s.rubyforge_project = "carrierwave-dynamoid"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "carrierwave"
  s.add_dependency "dynamoid"
  s.add_development_dependency "rspec", ["~> 2.0"]
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "pry"
  s.add_development_dependency "mocha"
end
