StripedRails::Application.routes.draw do
  mount Resque::Server, at: '/resque'

  root to: 'pages#index'

  match '/sign-in' => 'sessions#new', as: 'sign_in'
  match '/sign-out' => 'sessions#destroy', as: 'sign_out'
  resource :session, only: [:create]
  match '/sign-up(/:subscription_plan_id)' => 'users#new', as: 'sign_up'
  resources :users
  resource :profile, only: [:show,:edit,:update]
  resources :password_resets, only: [:new,:create,:edit,:update]
  resource :credit_card, only: [:new,:create]
  resource :subscription, only: [:update,:destroy]
  resource :dashboard, only: [:show]
  resources :subscription_plans, only: [:index,:edit,:update] do
    collection do
      get :available
    end
  end
  resources :coupons, only: [:index,:edit,:update]
  resources :coupon_subscription_plans, only: [:create,:destroy]
  resources :webhooks, only: :create
  resources :pages


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

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
