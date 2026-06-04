import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "chevron"]

    connect() {
    const isOpen = localStorage.getItem("topicsMenuOpen") === "true"
    if (isOpen) {
        this.menuTarget.classList.remove("hidden")
        this.chevronTarget.classList.add("rotate-180")
    }
    }

    toggle() {
    const isOpen = this.menuTarget.classList.toggle("hidden") === false
    this.chevronTarget.classList.toggle("rotate-180")

    localStorage.setItem("topicsMenuOpen", isOpen)
    }
}
