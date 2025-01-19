class AddInitialSchema < ActiveRecord::Migration[8.0]
  def change
    create_table :families do |t|
      t.string :name, null: false, index: true

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
