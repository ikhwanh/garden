import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "placeholder", "card", "sidebar", "main", "presetContent", "presetPlaceholder", "presetSidebar"]
  static values = { panelUrl: String, presetPanelUrl: String }

  select({ params: { cropId, nurseryId } }) {
    const isCrop = cropId !== undefined
    const id = String(isCrop ? cropId : nurseryId)

    this.sidebarTarget.classList.remove("hidden")
    this.mainTarget.classList.remove("w-full", "w-1/2", "w-1/3")
    this.placeholderTarget.classList.add("hidden")

    if (isCrop) {
      this.presetSidebarTarget.classList.remove("hidden")
      this.presetPlaceholderTarget.classList.add("hidden")
      this.mainTarget.classList.add("w-1/3")
    } else {
      this.presetSidebarTarget.classList.add("hidden")
      this.mainTarget.classList.add("w-1/2")
    }

    this.cardTargets.forEach(card => {
      const cardId = isCrop ? card.dataset.cropId : card.dataset.nurseryId
      const active = cardId === id && (isCrop ? "cropId" in card.dataset : "nurseryId" in card.dataset)
      card.classList.toggle("ring-gray-400", active)
      card.classList.toggle("ring-transparent", !active)
    })

    const param = isCrop ? `crop_id=${id}` : `nursery_id=${id}`

    this.contentTarget.innerHTML = '<p class="text-xs text-gray-400">Loading…</p>'
    fetch(`${this.panelUrlValue}?${param}`, { headers: { "X-Requested-With": "XMLHttpRequest" } })
      .then(r => r.text())
      .then(html => {
        this.contentTarget.innerHTML = html
        this.#scrollToNearest(this.contentTarget)
      })

    if (isCrop) {
      this.presetContentTarget.innerHTML = '<p class="text-xs text-gray-400">Loading…</p>'
      fetch(`${this.presetPanelUrlValue}?${param}`, { headers: { "X-Requested-With": "XMLHttpRequest" } })
        .then(r => r.text())
        .then(html => { this.presetContentTarget.innerHTML = html })
    }
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
