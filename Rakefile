require 'bundler/setup'
require 'bundler/gem_tasks'
require 'rake'

require 'rake/testtask'
Rake::TestTask.new(:spec) do |t|
  t.libs += %w[gcoder spec]
  t.test_files = FileList['spec/**/*.rb']
  t.verbose = true
end

task :default => :spec
