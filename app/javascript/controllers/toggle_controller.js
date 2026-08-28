import { Controller } from "@hotwired/stimulus"

// Generic show/hide toggle, e.g. for revealing an edit form on click.
export default class extends Controller {
  static targets = ["content"]

  toggle() {
    this.contentTarget.classList.toggle("d-none")
  }
}
