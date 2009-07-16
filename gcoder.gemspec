# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{gcoder}
  s.version = "0.3.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Carsten Nielsen"]
  s.date = %q{2009-07-16}
  s.email = %q{heycarsten@gmail.com}
  s.extra_rdoc_files = [
    "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "README.rdoc",
     "Rakefile",
     "VERSION.yml",
     "gcoder.gemspec",
     "lib/gcoder.rb",
     "lib/gcoder/config.rb",
     "lib/gcoder/geocoding_api.rb",
     "lib/gcoder/persistence.rb",
     "lib/gcoder/resolver.rb",
     "test/config_test.rb",
     "test/gcoder_test.rb",
     "test/geocoding_api_test.rb",
     "test/persistence_test.rb",
     "test/resolver_test.rb",
     "test/test_helper.rb"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/heycarsten/gcoder}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{A library for geocoding stuff through the Google Maps Geocoding API with a persisted cache via Tokyo Tyrant.}
  s.test_files = [
    "test/config_test.rb",
     "test/gcoder_test.rb",
     "test/geocoding_api_test.rb",
     "test/persistence_test.rb",
     "test/resolver_test.rb",
     "test/test_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
