require File.expand_path('../lib/gcoder/version', __FILE__)

Gem::Specification.new do |s|
  s.name              = 'gcoder'
  s.version           = GCoder::VERSION
  s.platform          = Gem::Platform::RUBY
  s.date              = Date.today.strftime('%F')
  s.homepage          = 'http://github.com/heycarsten/gcoder'
  s.authors           = ['Carsten Nielsen', 'Christos Pappas', 'GUI']
  s.email             = 'heycarsten@gmail.com'
  s.summary           = 'A nice library for geocoding stuff with Google Maps API V3'
  s.rubyforge_project = 'gcoder'
  s.files             = `git ls-files`.split("\n")
  s.test_files        = `git ls-files -- {test,spec}/*`.split("\n")
  s.require_paths     = ['lib']

  s.add_dependency             'hashie'
  s.add_dependency             'multi_json'
  s.add_dependency             'ruby-hmac'
  s.add_development_dependency 'bundler'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'redis'

  s.description = <<-END
Uses Google Maps Geocoding API (V3) to geocode stuff and optionally caches the
results somewhere.
  END
end
