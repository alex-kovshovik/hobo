class AddInitialSchema < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
    end

    create_table :families do |t|
      t.references :owner, null: false, foreign_key: { to_table: :users }
      t.string :name, null: false
    end

    create_table :family_members do |t|
      t.references :family, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
    end

    create_table :budgets do |t|
      t.references :family, null: false, foreign_key: true
      t.string :name, null: false
      t.decimal :amount, null: false, precision: 10, scale: 2
    end

    create_table :expenses do |t|
      t.references :budget, null: false, foreign_key: true
      t.decimal :amount, null: false, precision: 10, scale: 2
      t.date :date, null: false
    end
  end
end
