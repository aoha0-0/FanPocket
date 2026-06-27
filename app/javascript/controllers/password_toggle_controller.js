import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "input", "icon" ]

  connect() {
    // 初期状態：パスワード非表示（●●●）なので、
    // 次のアクションとして「目に斜線が入っているSVG（隠す）」を表示するために true を設定
    this.updateIcon(true)
  }

  toggle() {
    const isPassword = this.inputTarget.type === "password"
    
    // inputのtype属性を password ⇄ text で切り替え
    this.inputTarget.type = isPassword ? "text" : "password"
    
    // 状態に合わせてアイコンを切り替え
    this.updateIcon(!isPassword)
  }

  updateIcon(visible) {
    if (visible) {
      // 🟢 パスワード非表示（password）のとき：次に「隠す」ための斜線が入った目
      this.iconTarget.innerHTML = `
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-5 h-5">
          <path stroke-linecap="round" stroke-linejoin="round" d="M3.98 8.223A10.477 10.477 0 0 0 1.934 12C3.226 16.338 7.244 19.5 12 19.5c.993 0 1.953-.138 2.863-.395M6.228 6.228A10.451 10.451 0 0 1 12 4.5c4.756 0 8.773 3.162 10.065 7.498a10.522 10.522 0 0 1-4.293 5.774M6.228 6.228 3 3m3.228 3.228 3.65 3.65m7.822 7.822 3 3m-3-3-3.65-3.65m0 0a3 3 0 1 0-4.243-4.243m4.242 4.242L9.88 9.88" />
        </svg>
      `
    } else {
      // 🟢 パスワード表示中（text）のとき：次に「見る」ための普通の目
      this.iconTarget.innerHTML = `
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-5 h-5">
          <path stroke-linecap="round" stroke-linejoin="round" d="M2.036 12.322a1.012 1.012 0 0 1 0-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639C20.577 16.49 16.64 19.5 12 19.5c-4.638 0-8.573-3.007-9.963-7.178Z" />
          <path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z" />
        </svg>
      `
    }
  }
}