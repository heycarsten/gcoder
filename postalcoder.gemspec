# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{postalcoder}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Carsten Nielsen"]
  s.date = %q{2009-05-15}
  s.email = %q{heycarsten@gmail.com}
  s.extra_rdoc_files = [
    "README.rdoc"
  ]
  s.files = [
    "README.rdoc",
    "Rakefile",
    "VERSION.yml",
    "lib/postalcoder.rb",
    "lib/postalcoder/config.rb",
    "lib/postalcoder/formats.rb",
    "lib/postalcoder/geocoding_api.rb",
    "lib/postalcoder/persistence.rb",
    "lib/postalcoder/resolver.rb",
    "test/postalcoder_test.rb",
    "test/test_helper.rb"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/heycarsten/postalcoder}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{A library for geocoding postal codes via the Google Maps Geocoding API with a persisted cache through Tokyo Tyrant}
  s.test_files = [
    "test/postalcoder_test.rb",
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
