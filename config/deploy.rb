default_run_options[:pty] = true
set :scm, "git"
set :user, "neura"
set :application, "guild"
set :repository,  "git@github.com:dmauldin/rising-storm-guild-site.git"

ssh_options[:forward_agent] = true
set :branch, "master"
set :deploy_via, :remote_cache
set :git_shallow_clone, 1
set :git_enable_submodules, 1
set :use_sudo, false
set :deploy_to, "/home/#{user}/rails/#{application}"

role :app, "wheee.org"
role :web, "wheee.org"
role :db,  "wheee.org", :primary => true
