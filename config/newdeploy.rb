# config valid only for Capistrano 3.4 bundle exec cap -T
lock '3.4.1'

set :application, 'skillster'
set :repo_url, 'https://github.com/ayoa77/mypal.git'
set :branch, "frontend"

set :user, "aj"
set :rails_env, "production"
set :deploy_via, :remote_cache
set :keep_releases, 10
# server '139.162.107.188', user: 'aj', roles: %w{web app live}
# Default deploy_to directory is /var/www/my_app
server 'globetutoring.com', user: 'blnkk', roles: [:db]
set :deploy_to, '/home/aj/var/www/html/skillster/'

role :app, %w{139.162.107.188}
role :web, %w{139.162.107.188}
# server 'foo.example.org', user: 'runner',   roles: [:exec], port: 456
# role :db, %w{globetutoring.com}, user: 'aj', primary: true
# role :db, %w{139.162.107.188}
role :live, %w{139.162.107.188}



# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call


# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# sudo cp database.yml /home/aj/var/www/html/skillster/shared/config/ &&
# sudo cp paypal.yml /home/aj/var/www/html/skillster/shared/config/ && 
# sudo cp secrets.yml /home/aj/var/www/html/skillster/shared/config/ &&
# sudo cp application.yml /home/aj/var/www/html/skillster/shared/config/

# Default value for :linked_files is []
set :linked_files, %w{config/application.yml config/database.yml config/secrets.yml config/paypal.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}
set :linked_dirs, %w{tmp/pids tmp/cache public/system public/javascripts public/newsletters public/sitemaps}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }
# rename db/migrate/{20150526040154_create_settings.rb => 20150209161053_create_settings.rb} (77%)
# Default value for keep_releases is 5
# set :keep_releases, 5

# Give resque access to Rails environment
# set :resque_environment_task, true
# role :resque_worker, %w{139.162.107.188}
# role :resque_scheduler, %w{139.162.107.188}



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
  # role :resque_worker, %w{139.162.107.188}
  # role :resque_scheduler, %w{139.162.107.188}
  #
  # set :workers, { "email" => 1, "*" => 1, "location" => 1, "elasticsearch" => 1}


  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 4, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end
