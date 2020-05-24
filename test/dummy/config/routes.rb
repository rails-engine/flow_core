# frozen_string_literal: true

# For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
  resources :pipelines do
    member do
      post "deploy"
    end

    scope module: :pipelines do
      resources :steps, except: %i[index] do
        scope module: :steps do
          resources :branches, only: %i[new create]
          resources :transition_callbacks, except: %i[index]
          resource :transition_trigger, except: %i[index]
          resource :redirection, only: %i[show edit update]
        end

        collection do
          put "move"
        end
      end

      resources :branches, only: %i[show edit update destroy] do
        scope module: :branches do
          resources :arc_guards, except: %i[index]
          resources :steps, only: %i[new create] do
            collection do
              put "move"
            end
          end
        end
      end
    end
  end

  resources :workflows do
    scope module: :workflows do
      resources :instances, only: %i[new create]
      resources :transitions, only: %i[show update] do
        scope module: :transitions do
          resource :trigger, except: %i[show]
        end
      end
      resources :arcs, only: %i[edit update]
    end

    member do
      post "verify"
    end
  end
  resources :instances, only: %i[index show] do
    member do
      patch "activate"
    end

    scope module: :instances do
      resources :tasks, only: %i[] do
        member do
          patch "finish"
        end
      end
    end
  end

  resources :forms do
    collection do
      post "random"
    end

    scope module: :forms do
      resource :preview, only: %i[show create]
      resources :fields, except: %i[show] do
        collection do
          put "move"
        end
      end
    end
  end

  resources :fields, only: %i[] do
    scope module: :fields do
      resource :validations, only: %i[edit update]
      resource :options, only: %i[edit update]
      resource :data_source_options, only: %i[edit update]
      resources :choices, except: %i[show]
    end
  end

  resources :nested_forms, only: %i[] do
    scope module: :nested_forms do
      resources :fields, except: %i[show] do
        collection do
          put "move"
        end
      end
    end
  end

  resources :human_tasks, only: %i[show update]

  resources :notifications, only: %i[index]

  resources :users, except: %i[show]
  get "sign_in_as/:id", to: "session#sign_in_as", as: :sign_in_as
  delete "sign_out", to: "session#sign_out", as: :sign_out

  root to: "home#index"
end
