# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "json_schema_spec"
  spec.version       = "0.1.2"
  spec.authors       = ["Winton Welsh"]
  spec.email         = ["mail@wintoni.us"]
  spec.description   = %q{Generate fixtures from JSON schemas.}
  spec.summary       = %q{Generate fixtures from JSON schemas}
  spec.homepage      = "https://github.com/winton/json_schema_spec"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "json"
  spec.add_dependency "json-schema"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "simplecov"
end