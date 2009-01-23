default_run_options[:pty] = true
set :scm, "git"
set :user, "neura"
set :application, "guild"
set :repository,  "git@github.com:dmauldin/rising-storm-guild-site.git"
set :domain, "wheee.org"

ssh_options[:forward_agent] = true
set :branch, "master"
set :deploy_via, :remote_cache
set :git_shallow_clone, 1
set :git_enable_submodules, 1
set :use_sudo, false
set :deploy_to, "/home/#{user}/rails/#{application}"

role :app, domain
role :web, domain
role :db,  domain, :primary => true

namespace :deploy do
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end
 
  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end
end

desc "Symlink host specific config files"
task :after_update_code do
  run "ln -s #{deploy_to}/#{shared_dir}/config/database.yml #{deploy_to}/#{current_dir}/config/database.yml"
  run "ln -s #{deploy_to}/#{shared_dir}/config/initializers/site_keys.rb #{deploy_to}/#{current_dir}/config/initializers/site_keys.rb"
  run "ln -s #{deploy_to}/#{shared_dir}/config/initializers/hoptoad.rb #{deploy_to}/#{current_dir}/config/initializers/hoptoad.rb"
end
