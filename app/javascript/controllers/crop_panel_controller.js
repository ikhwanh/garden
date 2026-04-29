import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "card", "emptyState"]
  static values  = { detailPanelUrl: String }

  showDetail(event) {
    const { cropId, nurseryId } = event.params
    const isCrop = cropId !== undefined
    const id = String(isCrop ? cropId : nurseryId)

    this.cardTargets.forEach(card => {
      const match = isCrop
        ? card.dataset.cropPanelCropIdParam === id
        : card.dataset.cropPanelNurseryIdParam === id
      card.classList.toggle("border-l-green-400", match)
      card.classList.toggle("bg-green-50",         match)
      card.classList.toggle("border-l-transparent", !match)
    })

    this.emptyStateTarget.classList.add("hidden")
    this.contentTarget.classList.remove("hidden")
    this.contentTarget.innerHTML = '<p class="text-xs text-gray-400 p-6">Loading…</p>'

    const param = isCrop ? `crop_id=${id}` : `nursery_id=${id}`

    fetch(`${this.detailPanelUrlValue}?${param}`, { headers: { "X-Requested-With": "XMLHttpRequest" } })
      .then(r => r.text())
      .then(html => { this.contentTarget.innerHTML = html })
  }
}
