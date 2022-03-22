Rails.application.routes.draw do
  resources :runs, only: %i[index show create], param: 'slug'
end
