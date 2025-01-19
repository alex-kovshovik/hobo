Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  resources :budgets, only: %i[index] do
    collection do
      get ":date", to: "budgets#index", as: :date, constraints: { date: /\d{4}-\d{2}-\d{2}/ }, format: false
    end

    resources :expenses, only: %i[index create destroy] do
      collection do
        get ":date", to: "expenses#index", as: :date, constraints: { date: /\d{4}-\d{2}-\d{2}/ }, format: false
      end
    end
  end

  # Defines the root path route ("/")
  root "home#index"
end
