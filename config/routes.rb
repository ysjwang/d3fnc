Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  resources :kitchens do
  	 collection do
  	 	get 'd3fnc'
  	 	post 'test_d3fnc'
  	 	get 'render_d3fnc'
  	 end
  end

end
