# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary server in each group
# is considered to be the first unless any hosts have the primary
# property set.  Don't declare `role :all`, it's a meta role.

set :application, 'lionslounge'
set :repo_url, 'https://ayoa77:S6SMTfsmuF9vFRNeSy84@bitbucket.org/ayoa77/globetutoring.git'
set :branch, "frontend"

set :user, "aj"
set :rails_env, "production"
set :deploy_via, :remote_cache
set :keep_releases, 10
server '139.162.124.64', user: 'aj', roles: %w{web app db live}
# Default deploy_to directory is /var/www/my_app

role :app, %w{139.162.124.64}
role :web, %w{139.162.124.64}
role :db,  %w{139.162.124.64}
role :live, %w{139.162.124.64}

role :app, %w{139.162.124.64}
role :web, %w{139.162.124.64}
role :db,  %w{139.162.124.64}
role :live, %w{139.162.124.64}

role :resque_worker, %w{139.162.124.64}
role :resque_scheduler, %w{139.162.124.64}

# set :workers, { "email" => 1, "*" => 1, "location" => 1, "elasticsearch" => 1}
set :workers, {"*" => 1}
set :deploy_to, '/home/aj/var/www/html/lionslounge/'



# Extended Server Syntax
# ======================
# This can be used to drop a more detailed server definition into the
# server list. The second argument is a, or duck-types, Hash and is
# used to set extended properties on the server.

server '139.162.124.64', user: 'aj', roles: %w{web app db live}

set :rails_env, "production"

namespace :deploy do
  after :restart, "sitemap:refresh"
end


# Custom SSH Options
# ==================
# You may pass any option but keep in mind that net/ssh understands a
# limited set of options, consult[net/ssh documentation](http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start).
#
# Global options
# --------------
 set :ssh_options, {
   keys: %w(/Users/ayoamadi/.ssh/id_rsa),
   forward_agent: true,
 }
#
# And/or per server (overrides global)
# ------------------------------------
# server 'example.com',
#   user: 'user_name',
#   roles: %w{web app},
#   ssh_options: {
#     user: 'user_name', # overrides user setting above
#     keys: %w(/home/user_name/.ssh/id_rsa),
#     forward_agent: false,
#     auth_methods: %w(publickey password)
#     # password: 'please use keys'
#   }
# LoadModule passenger_module /home/aj/.rvm/gems/ruby-2.1.5@tutoring/gems/passenger-5.1.6/buildout/apache2/mod_passenger.so
# <IfModule mod_passenger.c>
#   PassengerRoot /home/aj/.rvm/gems/ruby-2.1.5@tutoring/gems/passenger-5.1.6
#   PassengerDefaultRuby /home/aj/.rvm/gems/ruby-2.1.5@tutoring/wrappers/ruby
# </IfModule>