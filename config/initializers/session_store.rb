# frozen_string_literal: true

Rails.application.config.session_store :cookie_store,
  key: "_hobo_session",
  expire_after: 14.days
