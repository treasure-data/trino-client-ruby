#!/usr/bin/env rake
require 'bundler/gem_tasks'

require 'rake/testtask'
require 'rake/clean'

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.fail_on_error = false
end

task :default => [:spec, :build]

GEN_MODEL_VERSIONS = %w[
  0.149
  0.153
  0.173
]

namespace "modelgen" do
  task :latest => :all do
    require 'erb'
    erb = ERB.new(File.read("modelgen/models.rb"))
    @versions = GEN_MODEL_VERSIONS
    @latest_version = GEN_MODEL_VERSIONS.last
    data = erb.result
    File.write("lib/presto/client/models.rb", data)
  end

  task :all => GEN_MODEL_VERSIONS

  GEN_MODEL_VERSIONS.each do |ver|
    file "build/presto-#{ver}.tar.gz" do
      mkdir_p "build"
      sh "curl -L -o build/presto-#{ver}.tar.gz https://github.com/facebook/presto/archive/#{ver}.tar.gz"
    end

    file "lib/presto/client/model_versions/#{ver}.rb" => "build/presto-#{ver}.tar.gz" do
      sh "tar zxf build/presto-#{ver}.tar.gz -C build"
      mkdir_p "lib/presto/client/model_versions"
      sh "#{RbConfig.ruby} modelgen/modelgen.rb #{ver} build/presto-#{ver} modelgen/model_versions.rb lib/presto/client/model_versions/#{ver}.rb"
      puts "Generated lib/presto/client/model_versions/#{ver}.rb."
    end

    task ver => "lib/presto/client/model_versions/#{ver}.rb"
  end
end

