require File.expand_path "lib/trino/client/version", File.dirname(__FILE__)

Gem::Specification.new do |gem|
  gem.name          = "trino-client"
  gem.version       = Trino::Client::VERSION

  gem.authors       = ["Sadayuki Furuhashi"]
  gem.email         = ["sf@treasure-data.com"]
  gem.description   = "Trino client library"
  gem.summary       = "Trino client library"
  gem.homepage      = "https://github.com/treasure-data/trino-client-ruby"
  gem.license       = "Apache-2.0"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7.0"

  gem.add_dependency "faraday", ">= 1", "< 3"
  gem.add_dependency "faraday_middleware", ["~> 1.0"]
  gem.add_dependency "msgpack", [">= 1.5.1"]

  gem.add_development_dependency "rake", [">= 0.9.2", "< 11.0"]
  gem.add_development_dependency "rspec", ["~> 2.13.0"]
  gem.add_development_dependency "webmock", ["~> 3.0"]
  gem.add_development_dependency "addressable", "~> 2.8.1" # 2.5.0 doesn't support Ruby 1.9.3
  gem.add_development_dependency "simplecov", "~> 0.22.0"
  gem.add_development_dependency "standard", "~> 1.12.1"
end
