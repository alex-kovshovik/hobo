export default class Expense {
  constructor(data) {
    this.digits = data.digits
    this.budgetId = data.budget_id
  }

  save() {
    const data = {
      digits: this.digits,
      budget_id: this.budgetId
    }

    const csrfToken = document.querySelector("meta[name=csrf-token]").content
    const formData = new FormData();
    for (const key in data) {
      formData.append(`expense[${key}]`, data[key]);
    }

    return fetch("/expenses", {
      method: 'POST',
      headers: {
        'X-CSRF-Token': csrfToken
      },
      body: formData
    })
    .then(response => response.json())
  }
}
