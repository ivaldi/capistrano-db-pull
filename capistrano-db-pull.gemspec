$:.push File.expand_path('../lib', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'capistrano-db-pull'
  s.version     = '0.0.1'
  s.licenses    = ['BSD-2-Clause']

  s.summary     = 'Download remote database to local database'
  s.description = 'Download remote database to local database, converting
                   between different formats'

  s.authors     = ['Frank Groeneveld']
  s.email       = ['frank@ivaldi.nl']
  s.homepage    = 'https://github.com/ivaldi/capistrano-db-pull'

  s.files       = `git ls-files`.split("\n")

  s.add_runtime_dependency 'capistrano', '~> 3.0'
end
