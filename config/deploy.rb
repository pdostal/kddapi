set :stages, %w(sorrel)
set :default_stage, 'sorrel'

set :scm, :git
set :format, :pretty
set :log_level, :info

set :keep_releases, 3

# set :linked_files, %w{}
set :linked_dirs,  %w{log tmp/pids tmp/sockets}

set :rbenv_type, :user
set :rbenv_ruby, File.read('.ruby-version').strip

set :puma_threads,    [4, 16]
set :puma_workers,    0

set :pty,             true
set :use_sudo,        false
set :deploy_via,      :remote_cache
set :puma_bind,       "unix://#{deploy_to}/tmp/sockets/puma.sock"
set :puma_state,      "#{release_path}/tmp/pids/puma.state"
set :puma_pid,        "#{release_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.error.log"
set :puma_error_log,  "#{release_path}/log/puma.access.log"
set :ssh_options,     { forward_agent: true, user: fetch(:user) }
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true

set :repo_url, 'git@github.com:pdostal/kddapi.git'

namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  before :start, :make_dirs do
    on roles(:app) do
      execute "mkdir #{release_path}/tmp/sockets -p"
      execute "mkdir #{release_path}/tmp/pids -p"
    end
  end
end

namespace :deploy do
  desc 'Restart application'
  after :finishing, :restart do
    on roles(:app), in: :sequence, wait: 5 do
      invoke 'puma:restart'
    end
  end

  desc 'Display server uptime'
  after :restart, :uptime do
    on roles(:web), in: :groups do
      uptime = capture(:uptime)
      "#{host.hostname} reports: #{uptime}"
    end
  end
end
