# lock '3.1.0'

set :stages, %w(production)
set :default_stage, 'production'
set :scm, :git
set :format, :pretty
set :log_level, :info

# set :pty, true
# set :default_env, { rvm_bin_path: '~/.rvm/bin' }
set :keep_releases, 3

namespace :deploy do

  after :publishing, :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :restart, :uptime do
    on roles(:web), in: :groups do
      uptime = capture(:uptime)
      "#{host.hostname} reports: #{uptime}"
    end
  end

end