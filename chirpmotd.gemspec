Gem::Specification.new do |s|
  s.name        = 'chirp_motd'
  s.version     = '1.0.0'
  s.executables << 'chirpmotd'
  s.excutables << 'cron_chirpmotd'
  s.date        = '2017-07-15'
  s.summary     = 'Invia su twitter citazioni, a tempo.'
  s.description = 'Una piccola gem per installare il servizio che permette di inviare tramite un account twitter delle citazioni. Le citazioni sono ottenute tramite un microservice ed inviate 1 al giorno per ciascun microservizio registrato.'
  s.authors     = ['TuxmAL']
  s.email       = 'tuxmal@gmail.com'
  s.files       = ["lib/chirp_motd.rb", "config/config.json", "lib/modules/fortune_quote.rb", "lib/modules/bofh_quote.rb", "lib/modules/doah_quote.rb", "lib/modules/bofh2_quote.rb", "lib/modules/advertise_me.rb", "bin/chirpmotd", "bin/cron_chirpmotd", "log/.gitignore"]
  s.homepage    = 'http://rubygems.org/gems/twitmotd'
  s.license       = 'GPL V3'
  s.requirements << 'twitter'
  s.requirements << 'logger'
  s.requirements << 'yaml'
  s.requirements << 'json'
  s.requirements << 'rubygems'
  s.requirements << 'net/http'
end
 
