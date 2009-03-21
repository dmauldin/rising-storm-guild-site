ActionController::Routing::Routes.draw do |map|
  map.resources :users, :has_one => [:password, :confirmation]
  map.resources :passwords
  map.resources :loots, :items, :raids, :toons
  map.resource :session

  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.register '/register', :controller => 'users', :action => 'create'
  map.signup '/signup', :controller => 'users', :action => 'new'

  map.root :controller => 'home', :action => 'index'
end
