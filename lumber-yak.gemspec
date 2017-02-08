require './lib/lumber-yak/version'

Gem::Specification.new do |s|
  s.name        = 'lumber-yak'
  s.version     = LumberYak::VERSION
  s.authors     = ['Mark Roddy']
  s.email       = ['mroddy@primary.com']
  s.homepage    = 'https://github.com/PrimaryKids/lumber-yak'
  s.summary     = "Structured Logging for Rails Applications"
  s.description = "LumberYak enables structured logging via JSON for any Rails application"
  s.license     = 'Apache'

  s.files = `git ls-files lib`.split("\n")

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rubocop', '0.43.0'

  s.add_runtime_dependency 'lograge'
  s.add_runtime_dependency 'activesupport', '>= 4', '< 5.1'
  s.add_runtime_dependency 'actionpack',    '>= 4', '< 5.1'
  s.add_runtime_dependency 'railties',      '>= 4', '< 5.1'
end
