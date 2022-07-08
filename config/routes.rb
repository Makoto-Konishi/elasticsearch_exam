require 'sidekiq/web'

Rails.application.routes.draw do
  resources :publishers
  resources :authors
  resources :categories
  resources :articles
  mount Sidekiq::Web, at: "/sidekiq" # sidekiqのダッシュボードを見れるようにするため
end
