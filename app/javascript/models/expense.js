export default class Expense {
  constructor(budgetId, digits, date, isRefund = false) {
    this.budgetId = budgetId
    this.digits = digits
    this.date = date
    this.isRefund = isRefund
  }

  save() {
    const csrfToken = document.querySelector("meta[name=csrf-token]").content
    const formData = new FormData();
    formData.append(`expense[digits]`, this.digits);
    formData.append(`expense[date]`, this.date);
    formData.append(`expense[is_refund]`, this.isRefund);

    return fetch(`/budgets/${this.budgetId}/expenses`, {
      method: 'POST',
      headers: {
        'X-CSRF-Token': csrfToken
      },
      body: formData
    })
    .then(response => response.json())
  }
}
