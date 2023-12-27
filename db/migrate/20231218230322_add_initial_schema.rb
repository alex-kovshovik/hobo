class AddInitialSchema < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.references :family, null: true, index: true

      t.string :first_name, null: false
      t.string :last_name, null: false

      ## Database authenticatable
      t.string :email,              null: false, default: "", index: true
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token, index: true
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      # t.integer  :sign_in_count, default: 0, null: false
      # t.datetime :current_sign_in_at
      # t.datetime :last_sign_in_at
      # t.string   :current_sign_in_ip
      # t.string   :last_sign_in_ip

      ## Confirmable
      # t.string   :confirmation_token
      # t.datetime :confirmed_at
      # t.datetime :confirmation_sent_at
      # t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      # t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at

      t.timestamps null: false
      t.userstamps
    end

    create_table :families do |t|
      t.references :owner, null: false, foreign_key: { to_table: :users }
      t.string :name, null: false

      t.timestamps null: false
      t.userstamps
    end

    create_table :budgets do |t|
      t.references :family, null: false, foreign_key: true
      t.string :name, null: false
      t.string :icon, null: false
      t.decimal :amount, null: false, precision: 10, scale: 2
      t.boolean :private, null: false, default: false

      t.timestamps null: false
      t.userstamps
    end

    create_table :expenses do |t|
      t.references :budget, null: false, foreign_key: true
      t.decimal :amount, null: false, precision: 10, scale: 2
      t.date :date, null: false

      t.timestamps null: false
      t.userstamps
    end
  end
end
