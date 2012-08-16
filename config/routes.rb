RedmineApp::Application.routes.draw do
  resources :configuration_items
  resources :configuration_item_relations
end
