Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :bikes
  resources :gasstands

  root to: 'pages#index'

  post "/set_gasstand", to: 'pages#set_gasstand'
end
