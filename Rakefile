#!/usr/bin/env rake
require 'bundler/gem_tasks'

require 'rake/testtask'
require 'rake/clean'

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => [:spec, :build]

GEN_MODEL_VERSIONS = %w[
  351
]

namespace "modelgen" do
  task :latest => :all do
    require 'erb'
    erb = ERB.new(File.read("modelgen/models.rb"))
    @versions = GEN_MODEL_VERSIONS
    @latest_version = GEN_MODEL_VERSIONS.last
    data = erb.result
    File.write("lib/trino/client/models.rb", data)
  end

  task :all => GEN_MODEL_VERSIONS

  GEN_MODEL_VERSIONS.each do |ver|
    file "build/trino-#{ver}.tar.gz" do
      mkdir_p "build"
      sh "curl -L -o build/trino-#{ver}.tar.gz https://github.com/trinodb/trino/archive/#{ver}.tar.gz"
    end

    file "lib/trino/client/model_versions/#{ver}.rb" => "build/trino-#{ver}.tar.gz" do
      sh "tar zxf build/trino-#{ver}.tar.gz -C build"
      mkdir_p "lib/trino/client/model_versions"
      sh "#{RbConfig.ruby} modelgen/modelgen.rb #{ver} build/trino-#{ver} modelgen/model_versions.rb lib/trino/client/model_versions/#{ver}.rb"
      puts "Generated lib/trino/client/model_versions/#{ver}.rb."
    end

    task ver => "lib/trino/client/model_versions/#{ver}.rb"
  end
end

