Rails.application.routes.draw do
  root "articles#index"

  resources :articles do
    resources :comments, only: [ :create, :destroy ]
  end

  namespace :api do
    resources :articles, except: [ :new, :edit ] do
      resources :comments, except: [ :new, :edit ]
    end
  end
end
