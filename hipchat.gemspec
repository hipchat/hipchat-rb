# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hipchat/version'

Gem::Specification.new do |spec|
  spec.name          = "hipchat"
  spec.version       = HipChat::VERSION
  spec.authors       = ["HipChat/Atlassian"]
  spec.email         = ["support@hipchat.com"]
  spec.description   = %q{Ruby library to interact with HipChat}
  spec.summary       = %q{Ruby library to interact with HipChat}
  spec.homepage      = "https://github.com/hipchat/hipchat-rb"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 1.9.3'

  spec.add_dependency "httparty"
  spec.add_dependency "mimemagic"

  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rr"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency 'rdoc', '> 2.4.2'
  spec.add_development_dependency 'coveralls'
end
