Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  resource :session
  resources :passwords, param: :token

  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Kill stale service workers from other apps that previously ran on this port
  get "pwa-service-worker.js", to: proc { [200, { "Content-Type" => "application/javascript" }, ["self.registration.unregister()"]] }
  get "apple-icon.png", to: proc { [404, {}, [""]] }

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
