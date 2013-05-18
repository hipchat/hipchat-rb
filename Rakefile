require "bundler/gem_tasks"

task :default => :spec

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = HipChat::VERSION

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "hipchat #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
