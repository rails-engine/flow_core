# frozen_string_literal: true

# For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
  resources :workflows do
    scope module: :workflows do
      resources :instances, only: %i[create]
      resources :transition_triggers, only: %i[edit update]
      resources :transitions, only: %i[show update]
      resources :arcs, only: %i[edit update]
    end

    member do
      post "verify"
    end
  end
  resources :instances, only: %i[index show] do
    member do
      patch "active"
    end

    scope module: :instances do
      resources :tasks, only: %i[] do
        member do
          patch "finish"
        end
      end
    end
  end

  resources :leaves do
    member do
      patch "initiate"
    end
  end
  resources :leave_approvals, only: %i[show update]
  resources :notifications, only: %i[index]

  resources :users, except: %i[show]
  get "sign_in_as/:id", to: "session#sign_in_as", as: :sign_in_as
  delete "sign_out", to: "session#sign_out", as: :sign_out

  root to: "home#index"
end
