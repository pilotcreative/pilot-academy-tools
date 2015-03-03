# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'trello_automation/version'

Gem::Specification.new do |spec|
  spec.name          = 'trello_automation'
  spec.version       = TrelloAutomation::VERSION
  spec.authors       = ['mateusz_kmiecinski', 'maciej_kalisz']
  spec.email         = ['m.kmiecinski@pilot.co', 'm.kalisz@pilot.co']
  spec.summary       = 'Script for automating humdrum Trello tasks'
  spec.homepage      = 'https://github.com/pilotcreative/pilot-academy-tools'
  spec.license       = 'MIT'
  spec.files         = %x{git ls-files -z}.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_runtime_dependency 'ruby-trello', '~> 1.1'
  spec.add_runtime_dependency 'launchy'
end
