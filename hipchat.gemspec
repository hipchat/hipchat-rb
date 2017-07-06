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

  if spec.respond_to?(:metadata=)
    spec.metadata = {
      "bug_tracker_uri" => "https://github.com/hipchat/hipchat-rb/issues",
      "changelog_uri"   => "https://github.com/hipchat/hipchat-rb/releases",
      "homepage_uri"    => "https://github.com/hipchat/hipchat-rb",
      "source_code_uri" => "https://github.com/hipchat/hipchat-rb",
    }
  end

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.0.0'

  spec.add_dependency "httparty"
  spec.add_dependency "mimemagic"

  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rr"
  spec.add_development_dependency "bundler", "> 1.15.0"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "webmock", "> 1.22.6"
  spec.add_development_dependency "addressable", "= 2.4.0"
  spec.add_development_dependency "term-ansicolor", "~> 1.4.0"
  spec.add_development_dependency "json", "> 1.8.4"
  spec.add_development_dependency 'rdoc', '> 2.4.2'
  spec.add_development_dependency 'tins', '~> 1.6.0'
  spec.add_development_dependency 'coveralls'
end
