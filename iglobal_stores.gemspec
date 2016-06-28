# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'iglobal_stores/version'

Gem::Specification.new do |spec|
  spec.name          = "iglobal_stores"
  spec.version       = IglobalStores::VERSION
  spec.authors       = ["Daniel LaBare"]
  spec.email         = ["dlabare@gmail.com"]
  spec.summary       = %q{ActiveMerchant extension for iGlobal Stores}
  spec.description   = %q{ActiveMerchant extension for iGlobal Stores}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.bindir        = "exe"
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
