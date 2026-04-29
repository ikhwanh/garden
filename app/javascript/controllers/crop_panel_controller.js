import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "card", "sidebar", "panelTitle"]
  static values = { presetPanelUrl: String }

  showPanel(event) {
    event.preventDefault()
    const { cropId, nurseryId, panel } = event.params
    const isCrop = cropId !== undefined
    const id = String(isCrop ? cropId : nurseryId)

    this.cardTargets.forEach(card => {
      const cardId = isCrop ? card.dataset.cropId : card.dataset.nurseryId
      const active = cardId === id && (isCrop ? "cropId" in card.dataset : "nurseryId" in card.dataset)
      card.classList.toggle("ring-gray-400", active)
      card.classList.toggle("ring-transparent", !active)
    })

    this.sidebarTarget.classList.remove("hidden")
    this.panelTitleTarget.textContent = "Preset"
    this.contentTarget.innerHTML = '<p class="text-xs text-gray-400">Loading…</p>'

    const param = isCrop ? `crop_id=${id}` : `nursery_id=${id}`

    fetch(`${this.presetPanelUrlValue}?${param}`, { headers: { "X-Requested-With": "XMLHttpRequest" } })
      .then(r => r.text())
      .then(html => {
        this.contentTarget.innerHTML = html
      })
  }
}
