# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'enhanced-wars/version'

Gem::Specification.new do |spec|
  spec.name          = "enhanced-wars"
  spec.version       = EnhancedWars::VERSION
  spec.authors       = ["Thorben Schröder"]
  spec.email         = ["stillepost@gmail.com"]
  spec.description   = %q{A turn based multiplayer strategy game}
  spec.summary       = %q{A turn based multiplayer strategy game}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "coffee-script"
  spec.add_dependency "sprockets", '~> 2.0'
  spec.add_dependency "json", "~> 1.7.7"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "thin"
end