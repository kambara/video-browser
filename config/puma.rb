root = "#{Dir.getwd}"

bind "unix://#{root}/tmp/socket"
pidfile "#{root}/tmp/pid"
state_path "#{root}/tmp/state"
rackup "#{root}/config.ru"

threads 4, 8

activate_control_app
