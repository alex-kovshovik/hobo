import { Controller } from "@hotwired/stimulus"
import Expense from "models/expense"

export default class extends Controller {
  static targets = [ "amount", "modal" ]
  static values = { digits: { type: Array, default: [] }, date: String }

  connect() {
    this.handlePopState = this.handlePopState.bind(this)
    window.addEventListener("popstate", this.handlePopState)
  }

  disconnect() {
    window.removeEventListener("popstate", this.handlePopState)
  }

  handlePopState(event) {
    if (this.isModalOpen()) {
      this.closeModalWithoutHistory()
    }
  }

  isModalOpen() {
    return this.modalTarget.classList.contains("is-active")
  }

  openModal() {
    history.pushState({ modal: "expense" }, "")
    this.modalTarget.classList.add("is-active")
    document.documentElement.classList.add("is-clipped")
  }

  closeModal() {
    if (this.isModalOpen()) {
      history.back()
    }
  }

  closeModalWithoutHistory() {
    this.modalTarget.classList.remove("is-active")
    document.documentElement.classList.remove("is-clipped")
    this.digitsValue = []
  }

  budgetPress(e) {
    const digits = this.digitsValue.join("")
    const budgetId = e.currentTarget.dataset.budgetId

    if (digits.length > 0) {
      e.preventDefault()
      const expense = new Expense(budgetId, digits, this.dateValue)
      expense.save()
        .then(data => {
          this.closeModal()
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
      newAmount = parseInt(this.digitsValue.join(""))
    }

    this.amount = newAmount
  }

  set amount(newAmount) {
    this.amountTarget.innerText = newAmount
  }
}
