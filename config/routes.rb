Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations',
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  devise_scope :user do
    get "users/edit_email",
        to: "users/registrations#edit_email",
        as: :edit_user_email

    patch "users/update_email",
          to: "users/registrations#update_email",
          as: :update_user_email
  end

  root "watchlists#index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  
  get 'terms', to: 'static_pages#terms'
  get 'privacy', to: 'static_pages#privacy'
  get 'guide', to: 'static_pages#guide', as: :guide
  # Defines the root path route ("/")
  # root "posts#index"

  get 'test_mail', to: 'watchlists#test_mail'

  namespace :internal do
    resources :notifications, only: :create
  end

  # 開発環境のみ letter_opener_web の画面を確認できるようにマウントする
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  resources :watchlists, only: [:index, :show, :new, :create, :edit, :update, :destroy]
  resources :notifications, only: [:index, :show]
  resource :settings, only: [:show, :update]
  resource :contact, only: [:new, :create]
  resource :onboarding, only: :update
  
  resources :url_parsers, only: [] do
    collection do
      get :fetch_title
    end
  end
  
  namespace :api do
    resources :date_suggestions, only: [:index]
  end
end
