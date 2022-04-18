require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'
  resources :runs, only: %i[index show create update], param: 'slug'
end
