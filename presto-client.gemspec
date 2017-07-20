require File.expand_path 'lib/presto/client/version', File.dirname(__FILE__)

Gem::Specification.new do |gem|
  gem.name          = "presto-client"
  gem.version       = Presto::Client::VERSION

  gem.authors       = ["Sadayuki Furuhashi"]
  gem.email         = ["sf@treasure-data.com"]
  gem.description   = %q{Presto client library}
  gem.summary       = %q{Presto client library}
  gem.homepage      = "https://github.com/treasure-data/presto-client-ruby"
  gem.license       = "Apache 2.0"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.has_rdoc = false

  gem.required_ruby_version = ">= 1.9.1"

  gem.add_dependency "faraday", ["~> 0.12"]
  gem.add_dependency "multi_json", ["~> 1.0"]
  gem.add_dependency "msgpack", [">= 0.7.0"]

  gem.add_development_dependency "rake", [">= 0.9.2", "< 11.0"]
  gem.add_development_dependency "rspec", ["~> 2.13.0"]
  gem.add_development_dependency "webmock", ["~> 2.0.0"]
  gem.add_development_dependency "addressable", ["~> 2.4.0"] # 2.5.0 doesn't support Ruby 1.9.3
  gem.add_development_dependency "simplecov", ["~> 0.10.0"]
end
