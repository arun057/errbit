Errbit::Application.routes.draw do
  # Hoptoad Notifier Routes
  match '/notifier_api/v2/notices', :controller => 'notices', :action => 'options', :constraints => {:method => 'OPTIONS'}
  match '/notifier_api/v2/notices' => 'notices#create'

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  match '/locate/:id' => 'notices#locate', :as => :locate
  match '/deploys.txt' => 'deploys#create'

  resources :notices,   :only => [:show]
  resources :deploys,   :only => [:show]
  resources :users do
    member do
      delete :unlink_github
    end
  end
  resources :problems,      :only => [:index] do
    collection do
      post :destroy_several
      post :resolve_several
      post :unresolve_several
      post :merge_several
      post :unmerge_several
      get :all
    end
  end

  resources :apps do
    resources :problems do
      resources :notices
      resources :comments, :only => [:create, :destroy]

      member do
        put :resolve
        put :unresolve
        post :create_issue
        delete :unlink_issue
      end
    end

    resources :deploys, :only => [:index]
  end

  namespace :api do
    namespace :v1 do
      resources :problems, :only => [:index], :defaults => { :format => 'json' }
      resources :notices, :only => [:index], :defaults => { :format => 'json' }
    end
  end

  root :to => 'apps#index'

end

