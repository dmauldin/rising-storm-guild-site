ActionController::Routing::Routes.draw do |map|
  map.resources :loots, :items, :raids, :toons
  map.root :controller => 'home', :action => 'index'
end
