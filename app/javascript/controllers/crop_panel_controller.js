import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "placeholder", "card"]

  select({ params: { cropId } }) {
    const id = String(cropId)

    this.placeholderTarget.classList.add("hidden")

    this.panelTargets.forEach(panel => {
      panel.classList.toggle("hidden", panel.dataset.cropId !== id)
    })

    this.cardTargets.forEach(card => {
      const active = card.dataset.cropId === id
      card.classList.toggle("ring-gray-400", active)
      card.classList.toggle("ring-transparent", !active)
    })
  }
}
