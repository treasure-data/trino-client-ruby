#!/usr/bin/env ruby
require File.expand_path 'lib/trino/client/version', File.dirname(__FILE__)

def run(cmd)
  puts cmd
  system cmd
end

run("gem build trino-client.gemspec")
run("gem push trino-client-#{Trino::Client::VERSION}.gem")

run("gem build trino-client-ruby/trino-client-ruby.gemspec")
run("gem push trino-client-ruby/trino-client-ruby-#{Trino::Client::VERSION}.gem")

