import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="form"
export default class extends Controller {
  static targets = ["submitbtn"]

  connect() {
    this.submitbtnTarget.hidden = true
  }

  autosumbit() {
    this.submitbtnTarget.click()
  }
}
