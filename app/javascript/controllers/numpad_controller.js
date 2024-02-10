import { Controller } from "@hotwired/stimulus"
import Expense from "models/expense"

export default class extends Controller {
  static targets = [ "amount", "budgetsFrame", "numpad" ]
  static values = { digits: { type: Array, default: [] }, date: String }

  budgetPress(e) {
    const digits = this.digitsValue.join("")
    const budgetId = e.currentTarget.dataset.budgetId

    if (digits.length > 0) {
      e.preventDefault()
      const expense = new Expense(budgetId, digits)
      expense.save()
        .then(data => {
          this.digitsValue = []
        })
        .catch(error => alert("Error: " + error))
    }
  }

  numPress(e) {
    const key = e.currentTarget.dataset.value

    switch (key) {
      case "CLR":
        this.digitsValue = []
        break
      case "DEL":
        this.digitsValue = this.digitsValue.slice(0, -1)
        break
      default:
        if (key !== "0" || this.digitsValue.length !== 0) this.digitsValue = [...this.digitsValue, key]
    }
  }

  digitsValueChanged() {
    let newAmount = 0

    if (this.digitsValue.length > 0) {
      newAmount = parseInt(this.digitsValue.join("")) / 100.0
    }

    this.amount = new Intl.NumberFormat("en-US", {style: "currency", currency: "USD"}).format(newAmount)
  }

  set amount(newAmount) {
    this.amountTarget.innerText = newAmount
  }
}
