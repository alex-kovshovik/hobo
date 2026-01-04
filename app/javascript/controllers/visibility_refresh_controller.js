import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["frame"]
  static values = {
    threshold: { type: Number, default: 30 },
    url: String
  }

  connect() {
    // Track when page was last active (visible + online)
    this.lastActiveAt = document.hidden ? null : Date.now()

    // Handle bfcache restoration (mobile browser back/forward cache)
    this.boundPageShow = this.handlePageShow.bind(this)
    window.addEventListener("pageshow", this.boundPageShow)

    // Handle network reconnection
    this.boundOnline = this.handleOnline.bind(this)
    window.addEventListener("online", this.boundOnline)
  }

  disconnect() {
    window.removeEventListener("pageshow", this.boundPageShow)
    window.removeEventListener("online", this.boundOnline)
  }

  // Called via data-action="visibilitychange@document->visibility-refresh#track"
  track() {
    if (document.hidden) {
      // Page becoming hidden - record last active time
      this.lastActiveAt = Date.now()
    } else {
      // Page becoming visible - check if stale
      this.checkAndRefresh()
    }
  }

  handlePageShow(event) {
    // bfcache restoration - always refresh if persisted
    if (event.persisted) {
      this.refresh()
    }
  }

  handleOnline() {
    // Network reconnected - refresh if page is visible
    if (!document.hidden) {
      this.refresh()
    }
  }

  checkAndRefresh() {
    if (!this.lastActiveAt) {
      // Page was hidden before we started tracking - refresh to be safe
      this.refresh()
      return
    }

    const elapsed = (Date.now() - this.lastActiveAt) / 1000
    if (elapsed >= this.thresholdValue) {
      this.refresh()
    }
  }

  refresh() {
    if (this.hasFrameTarget && this.hasUrlValue) {
      // Add cache-busting parameter to bypass service worker cache
      const url = new URL(this.urlValue, window.location.origin)
      url.searchParams.set("_t", Date.now())
      this.frameTarget.src = url.toString()
    }
    // Reset tracking
    this.lastActiveAt = Date.now()
  }
}
