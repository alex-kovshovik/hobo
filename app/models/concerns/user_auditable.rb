# frozen_string_literal: true

require "active_support/concern"

module UserAuditable
  extend ActiveSupport::Concern

  included do
    before_create do
      stamp_current_user(:created_by, :updated_by)
    end

    before_update do
      stamp_current_user(:updated_by)
    end
  end

  private

  def stamp_current_user(*attributes)
    return if Current.user.nil?

    Array(attributes).each do |attribute|
      write_attribute(attribute, Current.user.id)
    end
  end
end
