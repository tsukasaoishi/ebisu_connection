# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ebisu_connection/version'

Gem::Specification.new do |spec|
  spec.name          = "ebisu_connection"
  spec.version       = EbisuConnection::VERSION
  spec.authors       = ["tsukasaoishi"]
  spec.email         = ["tsukasa.oishi@gmail.com"]

  spec.summary       = %q{EbisuConnection supports connections with configured replica servers.}
  spec.description   = %q{https://github.com/tsukasaoishi/ebisu_connection}
  spec.homepage      = "https://github.com/tsukasaoishi/ebisu_connection"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.2'

  spec.add_dependency 'fresh_connection', '~> 3.0.0'

  spec.add_development_dependency 'mysql2', '>= 0.3.18', '< 0.6.0'
  spec.add_development_dependency 'pg', '>= 0.18', '< 2.0'
  spec.add_development_dependency "bundler", ">= 1.3.0", "< 2.0"
  spec.add_development_dependency "rake", ">= 0.8.7"
  spec.add_development_dependency 'appraisal'
  spec.add_development_dependency "minitest", "~> 5.10.0"
  spec.add_development_dependency "minitest-reporters"
end
