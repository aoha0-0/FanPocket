import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "message" ]

  static values = {
    text: String
  }

  async share() {
    if (navigator.share) {
      try {
        await navigator.share({
          text: this.textValue
        })
      } catch (error) {
        if (error.name !== "AbortError") {
          console.error("共有に失敗しました", error)
        }
      }
    } else {
      try {
        await navigator.clipboard.writeText(this.textValue)
        this.messageTarget.classList.remove("hidden")
      } catch (error) {
        console.error("コピーに失敗しました", error)
      }
    }
  }
}
