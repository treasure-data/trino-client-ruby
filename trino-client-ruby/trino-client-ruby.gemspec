require File.expand_path "../lib/trino/client/version", File.dirname(__FILE__)

Gem::Specification.new do |gem|
  gem.name          = "trino-client-ruby"
  gem.version       = Trino::Client::VERSION

  gem.authors       = ["Sadayuki Furuhashi"]
  gem.email         = ["sf@treasure-data.com"]
  gem.description   = "Trino client library"
  gem.summary       = "Trino client library"
  gem.homepage      = "https://github.com/treasure-data/trino-client-ruby"
  gem.license       = "Apache-2.0"

  gem.files         = ["lib/trino-client-ruby.rb"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7.0"

  gem.add_dependency "trino-client", Trino::Client::VERSION
end
