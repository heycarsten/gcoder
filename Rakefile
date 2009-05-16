require 'rubygems'
require 'rake'


begin
  require 'jeweler'
  Jeweler::Tasks.new do |g|
    g.name = 'postalcoder'
    g.summary = 'A library for geocoding postal codes via the Google Maps ' \
      'Geocoding API with a persisted cache through Tokyo Tyrant'
    g.email = 'heycarsten@gmail.com'
    g.homepage = 'http://github.com/heycarsten/postalcoder'
    g.authors = ['Carsten Nielsen']
  end
rescue LoadError
  puts 'Jeweler not available. Install it with: sudo gem install ' \
    'technicalpickles-jeweler -s http://gems.github.com'
end


require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end


begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/*_test.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort 'RCov is not available. In order to run rcov, you must: sudo gem ' \
      'install spicycode-rcov'
  end
end


task :default => :test

# require 'rake/rdoctask'
# Rake::RDocTask.new do |rdoc|
#   if File.exist?('VERSION.yml')
#     config = YAML.load(File.read('VERSION.yml'))
#     version = [config[:major], config[:minor], config[:patch]].join('.')
#   else
#     version = ''
#   end
#   rdoc.rdoc_dir = 'rdoc'
#   rdoc.title = "PostalCoder #{version}"
#   rdoc.rdoc_files.include('README*')
#   rdoc.rdoc_files.include('lib/**/*.rb')
# end
