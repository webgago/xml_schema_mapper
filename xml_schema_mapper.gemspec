# -*- encoding: utf-8 -*-
require File.expand_path('../lib/xml_schema_mapper/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Anton Sozontov"]
  gem.email         = ["a.sozontov@gmail.com"]
  gem.description   = %q{XMLSchemaMapper is your way to use XSD for XML}
  gem.summary       = %q{Bind you classes to xsd schema types and parse/build xml}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "xml_schema_mapper"
  gem.require_paths = ["lib"]

  gem.add_development_dependency "rspec"
  gem.add_development_dependency "guard-rspec"

  gem.add_runtime_dependency "activesupport"
  gem.add_runtime_dependency "nokogiri"

  gem.version       = XmlSchemaMapper::VERSION
end
