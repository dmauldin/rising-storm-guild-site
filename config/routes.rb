ActionController::Routing::Routes.draw do |map|
  map.resources :users, :has_one => [:password, :confirmation]
  map.resources :passwords
  map.resources :loots, :items, :raids, :toons
  map.resource :session
  map.resources :forums, :has_many => :topics
  map.resources :topics, :has_many => :posts
  map.resources :posts
  
  map.bank '/bank', :controller => 'guild_bank', :action => 'index'
  map.calendar '/calendar', :controller => 'calendar', :action => 'index'
  map.achievements '/achievements', :controller => 'achievements'
  
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.register '/register', :controller => 'users', :action => 'create'
  map.signup '/signup', :controller => 'users', :action => 'new'

  map.root :controller => 'home', :action => 'index'
end
