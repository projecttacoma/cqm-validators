# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cqm_validators/version'

Gem::Specification.new do |spec|
  spec.name          = 'cqm-validators'
  spec.version       = CqmValidators::VERSION
  spec.authors       = ['Laura', "Michael O'Keefe"]
  spec.email         = ['laclark@mitre.org', 'mokeefe@mitre.org']
  spec.license       = 'Apache-2.0'

  spec.summary       = 'new cqm validator library'
  spec.description   = 'new cqm validator library'
  spec.homepage      = 'https://github.com/projecttacoma/cqm-validators'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.5.0'

  spec.add_dependency 'nokogiri', '~>1.10'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'minitest-reporters'
  spec.add_development_dependency 'mongoid'
  spec.add_development_dependency 'overcommit'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rubocop', '~> 0.60'
end
