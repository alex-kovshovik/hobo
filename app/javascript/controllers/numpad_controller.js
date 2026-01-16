import { Controller } from "@hotwired/stimulus"
import Expense from "models/expense"

export default class extends Controller {
  static targets = [ "amount", "modal", "modalTitle", "budgetButtons" ]
  static values = { digits: { type: Array, default: [] }, date: String, isRefund: { type: Boolean, default: false } }

  connect() {
    this.handlePopState = this.handlePopState.bind(this)
    this.handleKeydown = this.handleKeydown.bind(this)
    // Use capture phase to handle before Turbo's popstate listener
    window.addEventListener("popstate", this.handlePopState, true)
    window.addEventListener("keydown", this.handleKeydown)
  }

  disconnect() {
    window.removeEventListener("popstate", this.handlePopState, true)
    window.removeEventListener("keydown", this.handleKeydown)
  }

  handleKeydown(event) {
    if (event.key === "Escape" && this.isModalOpen()) {
      this.closeModal()
    }
  }

  handlePopState(event) {
    if (this.isModalOpen()) {
      // Prevent Turbo from doing a restoration visit when we're just closing the modal
      event.stopImmediatePropagation()
      this.closeModalWithoutHistory()
    }
  }

  isModalOpen() {
    return this.modalTarget.classList.contains("is-active")
  }

  openModal(e) {
    this.isRefundValue = e.currentTarget.dataset.refund === "true"
    this.updateModalStyle()
    history.pushState({ modal: "expense" }, "")
    this.modalTarget.classList.add("is-active")
    document.documentElement.classList.add("is-clipped")
  }

  updateModalStyle() {
    const buttons = this.budgetButtonsTarget.querySelectorAll("button")

    if (this.isRefundValue) {
      this.modalTitleTarget.textContent = "Add Refund"
      this.modalTitleTarget.classList.remove("has-text-primary")
      this.modalTitleTarget.classList.add("has-text-warning")
      buttons.forEach(btn => {
        btn.classList.remove("is-light", "is-primary")
        btn.classList.add("is-warning")
      })
    } else {
      this.modalTitleTarget.textContent = "Add Expense"
      this.modalTitleTarget.classList.remove("has-text-warning")
      this.modalTitleTarget.classList.add("has-text-primary")
      buttons.forEach(btn => {
        btn.classList.remove("is-light", "is-warning")
        btn.classList.add("is-primary")
      })
    }
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
      const expense = new Expense(budgetId, digits, this.dateValue, this.isRefundValue)
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
