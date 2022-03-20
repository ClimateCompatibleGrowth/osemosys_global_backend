Rails.application.routes.draw do
  resources :runs, only: %i[index show create]
end
