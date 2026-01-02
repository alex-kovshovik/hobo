export default class Expense {
  constructor(budgetId, digits, date) {
    this.budgetId = budgetId
    this.digits = digits
    this.date = date
  }

  save() {
    const csrfToken = document.querySelector("meta[name=csrf-token]").content
    const formData = new FormData();
    formData.append(`expense[digits]`, this.digits);
    formData.append(`expense[date]`, this.date);

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
