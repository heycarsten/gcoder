# coding: utf-8
require File.expand_path("../lib/gcoder/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = 'gcoder'
  s.version     = GCoder::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Carsten Nielsen']
  s.email       = ['heycarsten@gmail.com']
  s.homepage    = 'http://github.com/heycarsten/gcoder'
  s.summary     = %q{A nice library for geocoding stuff with Google Geocoder API}
  s.description = %q{Uses Google Geocoder API to geocode stuff and optionally caches the results somewhere}

  s.required_rubygems_version = '>= 1.3.6'
  s.rubyforge_project = 'gcoder'

  s.add_dependency 'hashie'

  s.files         = `git ls-files`.split(?\n)
  s.test_files    = `git ls-files -- {test,spec}/*`.split(?\n)
  s.require_paths = ['lib']
end
