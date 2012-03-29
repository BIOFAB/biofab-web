BiofabWeb::Application.routes.draw do

  # authentication
  get 'logout' => 'sessions#destroy', :as => 'logout'
  get 'login' => 'sessions#new', :as => 'login'
  get 'signup' => 'users#new', :as => 'signup'
  resources :users
  resources :sessions

  # ActiveAdmin 
#  ActiveAdmin.routes(self)
#  devise_for :admin_users, ActiveAdmin::Devise.config

  # TODO fix this uncleanliness!
  get 'design_widgets' => 'designs#widgets', :as => 'design_widgets'
  get 'design_details' => 'designs#details', :as => 'design_details'
  get 'design_plasmid' => 'designs#plasmid', :as => 'design_plasmid'

  resources :strains
  resources :organisms
  resources :collections
  resources :eous
  resources :parts
  resources :characterization_types
  resources :measurement_types
  resources :performance_types
  resources :annotation_types
  resources :part_types

  namespace :admin do
    resources :users
  end

  match ':controller(/:action(/:id(.:format)))', :controller => /admin\/[^\/]+/

  match ':controller(/:action(/:id(.:format)))'

#  match 'user_admin(/:action(/:id))' => 'user_admin'
  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  root :to => 'front_page#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
