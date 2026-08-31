import { Controller } from "@hotwired/stimulus"

// Live-previews a list's color and emoji avatar as the picker is used,
// instead of only showing the result after saving.
export default class extends Controller {
  static targets = ["avatar"]

  previewColor(event) {
    this.element.style.setProperty("--accent", event.target.value)
  }

  previewEmoji(event) {
    if (this.hasAvatarTarget) {
      this.avatarTarget.textContent = event.target.value
    }
  }
}
