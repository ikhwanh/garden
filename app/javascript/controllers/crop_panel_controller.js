import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "placeholder", "card", "sidebar", "main"]

  select({ params: { cropId, nurseryId } }) {
    const isCrop = cropId !== undefined
    const id = String(isCrop ? cropId : nurseryId)

    this.sidebarTarget.classList.remove("hidden")
    this.mainTarget.classList.replace("w-full", "w-1/2")
    this.placeholderTarget.classList.add("hidden")

    let activePanel = null
    this.panelTargets.forEach(panel => {
      const panelId = isCrop ? panel.dataset.cropId : panel.dataset.nurseryId
      const visible = panelId === id
      panel.classList.toggle("hidden", !visible)
      if (visible) activePanel = panel
    })

    this.cardTargets.forEach(card => {
      const cardId = isCrop ? card.dataset.cropId : card.dataset.nurseryId
      const active = cardId === id && (isCrop ? "cropId" in card.dataset : "nurseryId" in card.dataset)
      card.classList.toggle("ring-gray-400", active)
      card.classList.toggle("ring-transparent", !active)
    })

    if (activePanel) this.#scrollToNearest(activePanel)
  }

  #scrollToNearest(panel) {
    const reminders = Array.from(panel.querySelectorAll("[data-reminder-due]"))
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
