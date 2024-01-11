import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "amount", "budgetsFrame" ]

  initialize() {
    this.digits = []
  }

  budgetPress(e) {
    // TODO: Add the expense submit call here and then reload the budgets frame!
    console.log("Budget button pressed", e.currentTarget.dataset.budgetId)
    this.budgetsFrameTarget.reload()
  }

  numPress(e) {
    const key = e.currentTarget.dataset.value

    switch (key) {
      case "CLR":
        this.digits = []
        break
      case "DEL":
        this.digits.pop()
        break
      default:
        if (key !== "0" || this.digits.length !== 0) this.digits.push(key)
    }

    this.renderAmount()
  }

  renderAmount() {
    let newAmount = 0

    if (this.digits.length > 0) {
      newAmount = parseInt(this.digits.join("")) / 100.0
    }

    this.amount = new Intl.NumberFormat("en-US", {style: "currency", currency: "USD"}).format(newAmount)
  }

  set amount(newAmount) {
    this.amountTarget.innerText = newAmount
  }
}
