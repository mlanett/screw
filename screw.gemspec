# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'screw/version'

Gem::Specification.new do |spec|
  spec.name          = "screw"
  spec.version       = Screw::VERSION
  spec.authors       = ["Mark Lanett"]
  spec.email         = ["mark.lanett@gmail.com"]
  spec.summary       = %q{Small classes to help bolt together a threaded application.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
