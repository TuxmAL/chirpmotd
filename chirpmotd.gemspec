Gem::Specification.new do |s|
  s.name        = 'chirp_motd'
  s.version     = '0.1.3'
  s.executables << 'chirpmotd'
  s.executables << 'cron_chirpmotd'
  s.date        = '2017-11-12'
  s.summary     = 'Invia su twitter citazioni, a tempo oppure singole. Ora fino a 280 caratteri.'
  s.description = 'Una piccola gem per installare il servizio che permette di inviare tramite un account twitter delle citazioni. Le citazioni sono ottenute tramite moduli ed inviate 1 al giorno per ciascun modulo aggiunto.'
  s.authors     = ['TuxmAL']
  s.email       = 'tuxmal@gmail.com'
  s.files       = ["lib/chirp_motd.rb", "lib/version.rb", "config/config.json"]
  s.files      += Dir["lib/modules/*.rb"]
  s.files      += Dir["bin/*"]
  s.homepage    = 'http://rubygems.org/gems/chirpmotd'
  s.license     = 'GPL-3.0'
  s.requirements << 'twitter'
  s.requirements << 'logger'
  s.requirements << 'yaml'
  s.requirements << 'json'
  s.requirements << 'rubygems'
  s.requirements << 'net/http'
end
 
