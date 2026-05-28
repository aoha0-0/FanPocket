Rails.application.routes.draw do
  devise_for :users
  root "watchlists#index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  get 'test_mail', to: 'watchlists#test_mail'


  get 'notification_test/run', to: 'notification_tests#run_test'
  get 'notification_test/cleanup', to: 'notification_tests#cleanup'

  # 開発環境のみ letter_opener_web の画面を確認できるようにマウントする
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  # config/routes.rb
  resources :watchlists, only: [:index, :show, :new, :create, :edit, :update, :destroy]
end
