import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // 自動消去するかどうかのスイッチ（デフォルトは true = 自動で消える）
  static values = { autoDismiss: { type: Boolean, default: true } }

  connect() {
    // もし autoDismiss が true のときだけ、3秒タイマーを動かす
    if (this.autoDismissValue) {
      setTimeout(() => {
        this.dismiss()
      }, 3000)
    }
  }

  // 手動でクリックした時も、ここが動いてフワッと消えます
  dismiss() {
    this.element.classList.add("opacity-0", "transition-opacity", "duration-500")

    setTimeout(() => {
      this.element.remove()
    }, 500)
  }
}