import { Controller } from "@hotwired/stimulus"

// Generic show/hide toggle. With more than one "content" target it flips
// them all at once, so a read-only view and its edit form can swap places.
export default class extends Controller {
  static targets = ["content"]

  toggle() {
    this.contentTargets.forEach((el) => el.classList.toggle("d-none"))
  }
}
