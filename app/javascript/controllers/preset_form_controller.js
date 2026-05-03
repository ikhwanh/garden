import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["harvestFields"]

  connect() {
    this.toggle()
  }

  toggle() {
    const growType = this.element.querySelector("[name='preset[grow_type]']")?.value
    const isNursery = growType === "nursery"
    this.harvestFieldsTargets.forEach(el => {
      el.style.display = isNursery ? "none" : ""
    })
  }
}
