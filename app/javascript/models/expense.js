export default class Expense {
  constructor(budgetId, digits) {
    this.budgetId = budgetId
    this.digits = digits
  }

  save() {
    const data = {
      digits: this.digits,
    }

    const csrfToken = document.querySelector("meta[name=csrf-token]").content
    const formData = new FormData();
    formData.append(`expense[digits]`, this.digits);

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
