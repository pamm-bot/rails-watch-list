import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static DEBOUNCE_MS = 300

  submit() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.element.requestSubmit()
    }, this.constructor.DEBOUNCE_MS)
  }
}
