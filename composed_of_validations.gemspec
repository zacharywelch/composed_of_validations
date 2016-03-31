# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'composed_of_validations/version'

Gem::Specification.new do |spec|
  spec.name          = "composed_of_validations"
  spec.version       = ComposedOfValidations::VERSION
  spec.authors       = ["zwelchcb"]
  spec.email         = ["Zachary.Welch@careerbuilder.com"]
  spec.summary       = %q{ActiveModel::Validations support for composed_of}
  spec.description   = %q{ActiveModel::Validations support for composed_of}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.2"
  spec.add_development_dependency "factory_girl", "~> 4.5.0"
  spec.add_development_dependency "sqlite3"
  spec.add_dependency "activerecord", "~> 4.2.0"
end
