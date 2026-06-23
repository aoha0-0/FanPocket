Rails.application.routes.draw do
  devise_for :user, controllers: {
    sessions: 'users/sessions'
  }

  root "watchlists#index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  
  get 'terms', to: 'static_pages#terms'
  get 'privacy', to: 'static_pages#privacy'
  # Defines the root path route ("/")
  # root "posts#index"

  get 'test_mail', to: 'watchlists#test_mail'

  # 開発環境のみ letter_opener_web の画面を確認できるようにマウントする
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  resources :watchlists, only: [:index, :show, :new, :create, :edit, :update, :destroy]
  resource :settings, only: [:show]
end
