require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

require File.dirname(__FILE__) + "/lib/json_schema_spec"
JsonSchemaSpec::Tasks.new("http://127.0.0.1:3000/schema.json")

RSpec::Core::RakeTask.new(:spec)
task :default => :spec