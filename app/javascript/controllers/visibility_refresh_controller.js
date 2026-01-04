import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["frame"]
  static values = {
    threshold: { type: Number, default: 30 },
    url: String
  }

  connect() {
    this.hiddenAt = null
  }

  // Called via data-action="visibilitychange@document->visibility-refresh#track"
  track() {
    if (document.hidden) {
      this.hiddenAt = Date.now()
    } else if (this.hiddenAt) {
      const elapsed = (Date.now() - this.hiddenAt) / 1000
      if (elapsed >= this.thresholdValue) {
        this.refresh()
      }
      this.hiddenAt = null
    }
  }

  refresh() {
    if (this.hasFrameTarget && this.hasUrlValue) {
      this.frameTarget.src = this.urlValue
    }
  }
}
