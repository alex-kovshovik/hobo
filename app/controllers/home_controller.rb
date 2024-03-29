# frozen_string_literal: true

class HomeController < ApplicationController
  before_action :redirect_authenticated_user

  def index; end

  private

  def redirect_authenticated_user
    redirect_to budgets_path if user_signed_in?
  end
end
