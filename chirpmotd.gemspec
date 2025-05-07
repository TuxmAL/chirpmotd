# frozen_String_literal: true

require_relative 'lib/version.rb'
Gem::Specification.new do |s|
  s.name        = 'chirp_motd'
  s.version     = ChirpQuote::VERSION
  s.executables << 'chirpmotd'
  s.executables << 'cron_chirpmotd'
  s.date        = File.mtime('lib/version.rb').strftime '%Y-%m-%d'
  s.summary     = 'Invia su twitter citazioni, a tempo oppure singole. Ora fino a 280 caratteri.'
  s.description = 'Una piccola gem per installare il servizio che permette di inviare tramite un account twitter delle citazioni. Le citazioni sono ottenute tramite moduli ed inviate 1 al giorno per ciascun modulo presente.'
  s.authors     = ['TuxmAL']
  s.email       = 'tuxmal@gmail.com'
  s.files       = ['lib/chirp_motd.rb', 'lib/version.rb', 'config/config.json', 'Gemfile']
  s.files      += Dir['lib/modules/*.rb']
  s.files      += Dir['bin/*']
  s.homepage    = 'http://rubygems.org/gems/chirpmotd'
  s.license     = 'GPL-3.0'
  s.required_ruby_version = '>= 3.1.0'
  s.requirements << 'mastodon-api'
  s.requirements << 'logger'
  s.requirements << 'mqtt'
  s.requirements << 'rubygems'
  s.requirements << 'net-http'
  s.add_dependency('mastodon-api', '~> 2.0')
  s.add_dependency('logger', '~> 1.6')
  s.add_dependency('mqtt', '~> 0.6.0')
  s.add_dependency('bundler', '~> 2.6')
end
