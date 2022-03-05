Rails.application.routes.draw do
  resources :runs, only: [:index]
end
