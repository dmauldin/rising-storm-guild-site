ActionController::Routing::Routes.draw do |map|
  map.resources :loots, :items, :raids
  map.root :controller => 'home', :action => 'index'
end
