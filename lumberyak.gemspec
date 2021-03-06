require './lib/lumberyak/version'

Gem::Specification.new do |s|
  s.name        = 'lumberyak'
  s.version     = LumberYak::VERSION
  s.authors     = ['Mark Roddy']
  s.email       = ['mroddy@primary.com']
  s.homepage    = 'https://github.com/PrimaryKids/lumberyak'
  s.summary     = "Structured Logging for Rails Applications"
  s.description = "LumberYak enables structured logging via JSON for any Rails application"
  s.license     = 'Apache'

  s.files = `git ls-files lib`.split("\n")

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rubocop', '0.49.0'

  s.add_dependency 'lograge'
  s.add_dependency 'activesupport', '>= 4', '< 5.1'
  s.add_dependency 'actionpack',    '>= 4', '< 5.1'
  s.add_dependency 'railties',      '>= 4', '< 5.1'
  s.add_dependency 'actionview',    '>= 4.2.11.1', '< 5.1'

  s.add_dependency "nokogiri", ">= 1.8.5"
  s.add_dependency "rack", ">= 1.6.11"
  s.add_dependency "loofah", ">= 2.2.3"
end
