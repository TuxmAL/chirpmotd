gem build chirpmotd.gemspec
gem install --local --user-install chirp_motd-0.1.1.gem
echo finalizing installation
cp config/config.json.last /home/tony/.gem/ruby/2.4.0/gems/chirp_motd-0.1.1/config/config.json
echo creating log file
su -c "echo >/var/log/chirpmotd.log && chmod a+rw /var/log/chirpmotd.log"
echo creating persisting dir
su -c "mkdir /var/lib/chirpmotd && chmod a+rwx /var/lib/chirpmotd"
echo done.
