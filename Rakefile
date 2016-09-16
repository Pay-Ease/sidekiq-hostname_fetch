require "bundler/gem_tasks"
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new

task :default do
  rspec = Rake::Task[:spec]
  rspec.invoke
end


Rake::Task['release'].clear

desc "Tag and release to gemfury under the 'citybase' organization"
task 'release' => 'release:source_control_push'  do
  Rake::Task['fury:release'].invoke('sidekiq-hostname_fetch.gemspec', 'citybase')
end
