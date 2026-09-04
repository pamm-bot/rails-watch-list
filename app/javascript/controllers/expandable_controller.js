import { Controller } from "@hotwired/stimulus"

// Clamp a block of text and reveal the rest on demand. The toggle hides
// itself when the text isn't actually long enough to be clamped.
export default class extends Controller {
  static targets = ["text", "button"]
  static values = { moreLabel: String, lessLabel: String }

  connect() {
    if (this.textTarget.scrollHeight <= this.textTarget.clientHeight + 1) {
      this.buttonTarget.hidden = true
    }
  }

  toggle() {
    const expanded = this.textTarget.classList.toggle("is-expanded")
    this.buttonTarget.textContent = expanded ? this.lessLabelValue : this.moreLabelValue
  }
}
