import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "amount", "budgetsFrame" ]
  static values = { digits: { type: Array, default: [] } }

  budgetPress(e) {
    const data = {
      digits: this.digitsValue.join(""),
      budget_id: e.currentTarget.dataset.budgetId
    }

    const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
    const formData = new FormData();
    for (const key in data) {
      formData.append(`expense[${key}]`, data[key]);
    }

    fetch("/expenses", {
      method: 'POST',
      headers: {
        'X-CSRF-Token': csrfToken
      },
      body: formData
    })
    .then(response => response.json())
    .then(data => {
      console.log('Success:', data);
      this.budgetsFrameTarget.reload()
      this.digitsValue = []

    })
    .catch((error) => {
      alert("Error: " + error)
    })
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
