import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "placeholder", "card", "sidebar", "main"]

  select({ params: { cropId } }) {
    const id = String(cropId)

    this.sidebarTarget.classList.remove("hidden")
    this.mainTarget.classList.replace("w-full", "w-1/2")
    this.placeholderTarget.classList.add("hidden")

    let activePanel = null
    this.panelTargets.forEach(panel => {
      const visible = panel.dataset.cropId === id
      panel.classList.toggle("hidden", !visible)
      if (visible) activePanel = panel
    })

    this.cardTargets.forEach(card => {
      const active = card.dataset.cropId === id
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
