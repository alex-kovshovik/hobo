# frozen_string_literal: true
require "active_support/concern"

module ControllerAuditable
  extend ActiveSupport::Concern

  included do
    before_action :set_audit_info
  end

  private

  def set_audit_info
    AuditService.set(current_user)
  end
end
