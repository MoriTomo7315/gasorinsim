Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :simsettings

  root to: 'pages#index'

  post "/simulate", to: 'pages#simulate'
  get "/simulate/result", to: 'pages#simulate_result'
end
