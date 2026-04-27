import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "placeholder", "card", "sidebar", "main"]
  static values = { panelUrl: String }

  select({ params: { cropId, nurseryId } }) {
    const isCrop = cropId !== undefined
    const id = String(isCrop ? cropId : nurseryId)

    this.sidebarTarget.classList.remove("hidden")
    this.mainTarget.classList.replace("w-full", "w-1/2")
    this.placeholderTarget.classList.add("hidden")

    this.cardTargets.forEach(card => {
      const cardId = isCrop ? card.dataset.cropId : card.dataset.nurseryId
      const active = cardId === id && (isCrop ? "cropId" in card.dataset : "nurseryId" in card.dataset)
      card.classList.toggle("ring-gray-400", active)
      card.classList.toggle("ring-transparent", !active)
    })

    const param = isCrop ? `crop_id=${id}` : `nursery_id=${id}`
    const url = `${this.panelUrlValue}?${param}`

    this.contentTarget.innerHTML = '<p class="text-xs text-gray-400">Loading…</p>'

    fetch(url, { headers: { "X-Requested-With": "XMLHttpRequest" } })
      .then(r => r.text())
      .then(html => {
        this.contentTarget.innerHTML = html
        this.#scrollToNearest(this.contentTarget)
      })
  }

  #scrollToNearest(container) {
    const reminders = Array.from(container.querySelectorAll("[data-reminder-due]"))
    if (!reminders.length) return

    const today = new Date().toISOString().slice(0, 10)
    let nearest = reminders[0]
    let nearestDiff = Infinity

    reminders.forEach(el => {
      const diff = Math.abs(new Date(el.dataset.reminderDue) - new Date(today))
      if (diff < nearestDiff) { nearestDiff = diff; nearest = el }
    })

    nearest.scrollIntoView({ block: "nearest", behavior: "smooth" })
  }
}
