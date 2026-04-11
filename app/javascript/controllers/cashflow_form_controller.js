import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["entryType", "costTypeField", "categorySelect"]
  static values = {
    incomeCategories: Array,
    expenseCategories: Array
  }

  connect() {
    this.update()
  }

  update() {
    const type = this.entryTypeTarget.value
    const isExpense = type === "expense"

    // Show/hide cost_type field
    this.costTypeFieldTarget.classList.toggle("hidden", !isExpense)

    // Swap category options
    const categories = isExpense ? this.expenseCategoriesValue : this.incomeCategoriesValue
    const current = this.categorySelectTarget.value
    const select = this.categorySelectTarget

    select.innerHTML = `<option value="">Select…</option>` +
      categories.map(c =>
        `<option value="${c}" ${c === current ? "selected" : ""}>${this.#label(c)}</option>`
      ).join("")
  }

  #label(value) {
    return value.replace(/_/g, " ").replace(/\b\w/g, c => c.toUpperCase())
  }
}
