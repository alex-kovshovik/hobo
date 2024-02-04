Rails.application.routes.draw do
  devise_for :users

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  resources :expenses, only: %i[index create destroy] do
    collection do
      get ":date", to: "expenses#index", as: :date, constraints: { date: /\d{4}-\d{2}-\d{2}/ }, format: false
    end
  end

  resources :budgets, only: %i[index show] do
    collection do
      get ":date", to: "budgets#index", as: :date, constraints: { date: /\d{4}-\d{2}-\d{2}/ }, format: false
    end
  end

  # Defines the root path route ("/")
  root "home#index"
end
