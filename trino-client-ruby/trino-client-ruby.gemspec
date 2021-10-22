require File.expand_path '../lib/trino/client/version', File.dirname(__FILE__)

Gem::Specification.new do |gem|
  gem.name          = "trino-client-ruby"
  gem.version       = Trino::Client::VERSION

  gem.authors       = ["Sadayuki Furuhashi"]
  gem.email         = ["sf@treasure-data.com"]
  gem.description   = %q{Trino client library}
  gem.summary       = %q{Trino client library}
  gem.homepage      = "https://github.com/treasure-data/trino-client-ruby"
  gem.license       = "Apache-2.0"

  gem.files         = ['lib/trino-client-ruby.rb']
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 1.9.1"

  gem.add_dependency "trino-client", Trino::Client::VERSION
end
