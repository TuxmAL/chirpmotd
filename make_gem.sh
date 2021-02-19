gem build chirpmotd.gemspec
gem uninstall chirp_motd
#PATH="$(ruby -e 'print Gem.user_dir')/bin:$PATH"

gem install --local --user-install chirp_motd-0.1.5.gem
echo finalizing installation
# cp config/config.json.good /home/tony/.gem/ruby/2.4.0/gems/chirp_motd-0.1.3/config/config.json
echo creating log file
su -c "echo >/var/log/chirpmotd.log && chmod a+rw /var/log/chirpmotd.log"
echo creating persisting dir
su -c "mkdir /var/lib/chirpmotd && chmod a+rwx /var/lib/chirpmotd"
echo done.
