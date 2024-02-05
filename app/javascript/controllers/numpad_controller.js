import { Controller } from "@hotwired/stimulus"
import Expense from "models/expense"

export default class extends Controller {
  static targets = [ "amount", "budgetsFrame", "numpad" ]
  static values = { digits: { type: Array, default: [] } }

  budgetPress(e) {
    const data = {
      digits: this.digitsValue.join(""),
      budget_id: e.currentTarget.dataset.budgetId
    }

    if (data.digits.length > 0) {
      const expense = new Expense(data)
      expense.save()
        .then(data => {
          this.budgetsFrameTarget.reload()
          this.digitsValue = []
        })
        .catch(error => alert("Error: " + error))
    } else {
      // Budget pressed without an amount - show this budget within a frame
      this.amount = e.currentTarget.dataset.budgetName
      this.numpadTarget.classList.add("hidden")
      this.budgetsFrameTarget.src = `/budgets/${data.budget_id}?date=`
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
