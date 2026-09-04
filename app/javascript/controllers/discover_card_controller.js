import { Controller } from "@hotwired/stimulus"

// Drives one discovery card: "Have you seen this?" -> "Did you like it?" /
// "Would you like to?" -> submit. Buttons only, with a slide-out on answer
// and a fade-in when the next card arrives.
export default class extends Controller {
  static targets = ["form", "step", "seenField", "verdictField"]

  connect() {
    this.showStep("seen")
    this.element.classList.add("is-entering")
    requestAnimationFrame(() => this.element.classList.remove("is-entering"))
  }

  answerSeen(event) {
    const yes = String(event.params.choice) === "1"
    this.seenFieldTarget.value = yes ? "1" : "0"
    this.showStep(yes ? "liked" : "want")
  }

  answerVerdict(event) {
    this.verdictFieldTarget.value = event.params.choice
    this.element.classList.add("is-leaving")
    setTimeout(() => this.formTarget.requestSubmit(), 180)
  }

  showStep(name) {
    this.stepTargets.forEach((el) => {
      el.classList.toggle("d-none", el.dataset.step !== name)
    })
  }
}
