import { Controller } from "@hotwired/stimulus"

// Makes a <select>'s blank option look like a text-field placeholder
// (muted color) instead of a normal chosen value.
export default class extends Controller {
  connect() {
    this.update()
  }

  update() {
    this.element.classList.toggle("select-placeholder", this.element.value === "")
  }
}
