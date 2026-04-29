import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["day"]
  static values  = { dayUrl: String }

  selectDay(event) {
    const date = String(event.params.date)

    this.dayTargets.forEach(el => {
      const selected = el.dataset.fertilizationCalendarDateParam === date
      el.classList.toggle("bg-green-50",    selected)
      el.classList.toggle("ring-2",         selected)
      el.classList.toggle("ring-inset",     selected)
      el.classList.toggle("ring-green-400", selected)
    })

    const frame = document.getElementById("day-detail")
    if (frame) frame.src = `${this.dayUrlValue}?date=${date}`
  }
}
