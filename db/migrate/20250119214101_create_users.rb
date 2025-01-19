class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.references :family, null: true, index: true

      t.string :email_address, null: false
      t.string :password_digest, null: false

      t.string :first_name, null: false
      t.string :last_name, null: false
      t.boolean :admin, null: false, default: true

      t.timestamps
      t.userstamps
    end

    add_index :users, :email_address, unique: true
  end
end
