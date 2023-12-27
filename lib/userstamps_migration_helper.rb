module UserstampsMigrationHelper
  def userstamps
    column :created_by, :bigint, null: true
    column :updated_by, :bigint, null: true
  end
end
