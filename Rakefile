#!/usr/bin/env rake
require 'bundler/gem_tasks'

require 'rake/testtask'
require 'rake/clean'

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.fail_on_error = false
end

task :default => [:spec, :build]

GEN_MODELS_VERSION = "0.134"

task :modelgen do
  unless Dir.exists?("presto-#{GEN_MODELS_VERSION}")
    sh "curl -L -o presto-#{GEN_MODELS_VERSION}.tar.gz https://github.com/facebook/presto/archive/#{GEN_MODELS_VERSION}.tar.gz"
    sh "tar zxvf presto-#{GEN_MODELS_VERSION}.tar.gz"
  end

  sh "#{RbConfig.ruby} modelgen/modelgen.rb presto-#{GEN_MODELS_VERSION} modelgen/models.rb lib/presto/client/models.rb"
  puts "Generated lib/presto/client/models.rb."
end

