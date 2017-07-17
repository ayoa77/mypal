# config valid only for Capistrano 3.1
lock '3.2.1'

set :application, 'blnkk'
set :repo_url, 'git@gerbenmeyer.nl:blnkk'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/home/deploy/www/blnkk'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{config/application.yml config/database.yml config/secrets.yml config/paypal.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}
set :linked_dirs, %w{tmp/pids tmp/cache public/system public/javascripts public/newsletters public/sitemaps}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Give resque access to Rails environment
set :resque_environment_task, true

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      execute :touch, release_path.join('tmp/restart.txt')
      with rails_env: :production do
        within release_path do
          execute :rake, 'db:inject_settings'
          execute :rake, 'db:elasticsearch_import'
          execute :rake, 'db:recalculate'
          execute :rake, 'db:clear_logs'
          execute :rake, 'websocket:restart'
          execute :rake, 'i18n:js:export'
        end
      end
    end
  end

  after :publishing, :restart

  after :restart, "resque:restart"

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end
