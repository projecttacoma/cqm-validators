
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

  spec.add_dependency 'nokogiri', '~>1.8.2'
  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rake', '~> 10.0'
end
