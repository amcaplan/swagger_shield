# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "swagger_shield/version"

Gem::Specification.new do |spec|
  spec.name          = "swagger_shield"
  spec.version       = SwaggerShield::VERSION
  spec.authors       = ["amcaplan"]
  spec.email         = ["arielmcaplan@gmail.com"]

  spec.summary       = %q{Protect your API from malformed requests with Swagger Shield!}
  spec.description   = %q{Validates requests to your Rails API against your Swagger spec.}
  spec.homepage      = "https://github.com/amcaplan/swagger_shield"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "json-schema", "~> 2.5"

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rails", "~> 5.0"
  spec.add_development_dependency "rspec-rails", "~> 3.6"
  spec.add_development_dependency "pry", "~> 0"
end
