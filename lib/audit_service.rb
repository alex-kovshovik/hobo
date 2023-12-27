class AuditService
  def self.set(user)
    Thread.current.thread_variable_set(:current_user, user)
  end

  def self.current_user
    Thread.current.thread_variable_get(:current_user)
  end
end
