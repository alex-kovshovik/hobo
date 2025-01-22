# frozen_string_literal: true

# The CSV file was produced by the following SQL:
#
# select
#   e.id,
#   b.name as budget,
#   e.amount,
#   e.date,
#   u.first_name
# from expenses e
# join budgets b on b.id = e.budget_id
# join users u on u.id = e.created_by

require "csv"

CSV.foreach("tmp/expenses.csv", headers: true) do |row|
  budget = Budget.find_by(name: row["budget"])
  next if budget.nil?

  user = User.find_by!(first_name: row["first_name"])

  budget.expenses.create!(
    amount: row["amount"],
    date: row["date"],
    created_by: user.id
  )
end
