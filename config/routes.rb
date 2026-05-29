Rails.application.routes.draw do
  resources :categories, only: [:index, :show, :create, :update, :destroy]
  resources :equipment, only: [:index, :show, :create, :update, :destroy]
  resources :maintenance_records, only: [:index, :show, :create, :update, :destroy]
end