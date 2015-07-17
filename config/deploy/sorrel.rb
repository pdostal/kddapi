role :app, %w{www@sorrel.pdostal.cz}

set :stage, 'sorrel'
set :branch, ENV["REVISION"] || "master"
set :tmp_dir, "/home/www/tmp"
set :deploy_to, '/home/www/kddapi.pdostal.cz'

server 'sorrel.pdostal.cz', port: 63022, user: 'www', roles: %w{app}
