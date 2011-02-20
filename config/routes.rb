ActionController::Routing::Routes.draw do |map|
  map.resources :solutions

  map.resources :tooltips

  map.resources :tasks

  map.resources :faqs

  map.resources :blanks

  map.resources :investigatings


  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  
    map.resources :challenges, :collection => {:all => :get, :incomplete => :get, :completed => :get, :featured => :get, :popular => :get, :nearby => :get, :recent => :get}
  
  # Sample resource route with more complex sub-resources
  map.resources :investigations, :has_many => [:tags], :member => {:spark=>:get, :publish => :post, :moderate => :post, :trash => :post, :lock => :post, :unlock => :post, :feature => :post, :unfeature => :post, :complete => :post, :uncomplete => :post, :update_views => :any}, :collection => {:mine => :get, :featured => :get, :popular => :get, :nearby => :get, :recent => :get, :completed => :get} do |investigations|
      investigations.resources :investigatings
      investigations.resources :challenges, :member => {:publish => :post, :moderate => :post, :trash => :post, :lock => :post, :unlock => :post, :feature => :post, :unfeature => :post, :complete => :post, :uncomplete => :post} do |challenges|
       challenges.resources :tasks , :member => {:toggle => :put }
       challenges.resources :comments, :member => {:publish => :post, :moderate => :post, :trash => :post}
       
      end
      investigations.resources :activities
      investigations.resources :comments, :member => {:publish => :post, :moderate => :post, :trash => :post}
      investigations.resources :blanks, :member => {:publish => :post, :moderate => :post, :trash => :post} do |blanks|
        blanks.resources :comments, :member => {:publish => :post, :moderate => :post, :trash => :post}
      end
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  end
  
  map.resources :faqs


  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  
  # Add this after any of your own existing routes, but before the default rails routes:
  map.from_plugin :community_engine

  map.connect ':controller/:action/:id/'
  map.connect ':controller/:action/:id.:format'
  # Install the default routes as the lowest priority.
  map.connect ':controller/:id/:action'
  map.connect ':controller/:id/:action.:format'
  
end
