import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ 
    "titleInput", "titleErrorMessage",
    "urlInput", "fetchButton", "noticeMessage", 
    "startAtInput", "startErrorMessage", 
    "endAtInput", "errorMessage",
    "suggestionsContainer" 
  ]

  // 画面が表示された時、およびTurboで画面が書き換わった時に毎回確実に動く魔法
  initialize() {
    this.checkTitle = this.checkTitle.bind(this)
    this.checkStartDate = this.checkStartDate.bind(this)
    this.checkDate = this.checkDate.bind(this)
  }

  connect() {
    // 画面が開いた瞬間、すでに文字が入っていればチェックを1回走らせる
    this.checkAll()

   // Flatpickrの準備を待って、確実にイベントを仕込む
    this.bindFlatpickr()
  }

  // すべてを一括でチェックする安全用の関数
  checkAll() {
    if (this.hasTitleInputTarget) this.checkTitle()
    if (this.hasStartAtInputTarget) this.checkStartDate()
    if (this.hasEndAtInputTarget) this.checkDate()
  }

  bindFlatpickr() {
    let attempts = 0
    const interval = setInterval(() => {
      attempts++
      
      const startConnected = this.hasStartAtInputTarget && this.startAtInputTarget._flatpickr
      const endConnected = this.hasEndAtInputTarget && this.endAtInputTarget._flatpickr

      if (startConnected || endConnected) {
        clearInterval(interval)
        
        if (startConnected) {
          this.startAtInputTarget._flatpickr.set('onChange', this.checkStartDate)
          this.startAtInputTarget._flatpickr.set('onClose', this.checkStartDate)
        }
        
        if (endConnected) {
          this.endAtInputTarget._flatpickr.set('onChange', this.checkDate)
          this.endAtInputTarget._flatpickr.set('onClose', this.checkDate)
        }
      } else if (attempts > 10) {
        clearInterval(interval)
      }
    }, 100)
  }

  // タイトルのチェック
  checkTitle() {
    if (!this.hasTitleInputTarget || !this.hasTitleErrorMessageTarget) return
    const titleValue = this.titleInputTarget.value.trim()

    if (titleValue.length > 0) {
      this.titleErrorMessageTarget.classList.add("hidden")
    } else {
      this.titleErrorMessageTarget.classList.remove("hidden")
    }
  }

  // タイトルを自動取得するメイン処理
  async fetchTitle() {
    const url = this.urlInputTarget.value.trim()
    if (!url) {
      this.showNotice("URLを入力してください", "text-error")
      return
    }

    this.setLoading(true)

    try {
      const response = await fetch(`/url_parsers/fetch_title?url=${encodeURIComponent(url)}`)
      const data = await response.json()

      if (response.ok && data.title) {
        this.titleInputTarget.value = data.title
        this.showNotice("タイトルを取得しました！", "text-success text-primary")
      
        if (typeof this.checkTitle === "function") {
          this.checkTitle()
        }

        // ✨ タイトル取得成功時、日時候補も一緒に裏で取得
        this.fetchDateSuggestions(url)

      } else {
        this.showNotice(data.error || "タイトルが取得できませんでした", "text-neutral-500 font-normal")
      }
    } catch (error) {
      console.error(error)
      this.showNotice("タイトルが取得できませんでした", "text-neutral-500 font-normal")
    } finally {
      this.setLoading(false)
    }
  }

  // ✨ 日時候補の取得
  async fetchDateSuggestions(url) {
    try {
      const response = await fetch(`/api/date_suggestions?url=${encodeURIComponent(url)}`)
      const data = await response.json()

      if (response.ok && data.suggestions && data.suggestions.length > 0) {
        this.renderDateSuggestions(data.suggestions)
      }
    } catch (error) {
      console.error("日時候補の取得に失敗しました:", error)
    }
  }

  // ✨ ボタンを画面に生成
  renderDateSuggestions(suggestions) {
    if (!this.hasSuggestionsContainerTarget) return

    this.suggestionsContainerTarget.innerHTML = "" // 一旦クリア

    suggestions.forEach(suggestion => {
      const button = document.createElement("button")
      button.type = "button"
      // DaisyUIの小さめで控えめなボタンデザイン
      button.className = "btn btn-xs btn-outline btn-primary mr-2 mb-2 normal-case font-normal"
      button.textContent = suggestion.label

      // ボタンをクリックしたら、対応する入力欄に値をセット
      button.addEventListener("click", () => {
        this.insertDateTime(suggestion.label, suggestion.value)
      })

      this.suggestionsContainerTarget.appendChild(button)
    })
  }

  // ✨ おもてなし入力ロジック
  insertDateTime(label, value) {
    let targetInput = null

    // ラベルに「開始」が含まれていれば開始入力欄へ、それ以外（締切や候補）なら締切入力欄を優先
    if (label.includes("開始") && this.hasStartAtInputTarget) {
      targetInput = this.startAtInputTarget
    } else if (this.hasEndAtInputTarget) {
      targetInput = this.endAtInputTarget
    }

    if (!targetInput) return

    // Flatpickrインスタンスがあればそこからセット、なければ直接valueにセット
    if (targetInput._flatpickr) {
      targetInput._flatpickr.setDate(value, true) // trueで変化イベントを発火させてバリデーションを通す
    } else {
      targetInput.value = value
      // 直接セットした場合は手動でバリデーションを発火
      this.checkStartDate()
      this.checkDate()
    }
  }

  showNotice(message, colorClass) {
    this.noticeMessageTarget.textContent = message
    this.noticeMessageTarget.className = `text-xs font-semibold pl-4 flex items-center gap-1 ${colorClass}`
  }

  // ボタンのローディング状態を切り替えるヘルパーメソッド
  setLoading(isLoading) {
    if (isLoading) {
      this.fetchButtonTarget.disabled = true
      this.fetchButtonTarget.classList.add("opacity-60", "cursor-not-allowed")
      this.fetchButtonTarget.querySelector("[data-watchlist-form-target='buttonText']").textContent = "取得中..."
    } else {
      this.fetchButtonTarget.disabled = false
      this.fetchButtonTarget.classList.remove("opacity-60", "cursor-not-allowed")
      this.fetchButtonTarget.querySelector("[data-watchlist-form-target='buttonText']").textContent = "タイトルを自動取得する"
    }
  }

  // 開始日時のチェック
  checkStartDate() {
    if (!this.hasStartAtInputTarget || !this.hasStartErrorMessageTarget) return
    const inputDateValue = this.startAtInputTarget.value
    if (!inputDateValue) return

    const normalizedString = inputDateValue.replace(/\//g, '-')
    const inputDate = new Date(normalizedString)
    const now = new Date()

    if (inputDate >= now) {
      this.startErrorMessageTarget.classList.add("hidden")
    } else {
      this.startErrorMessageTarget.classList.remove("hidden")
    }
  }

  // 締切日時のチェック
  checkDate() {
    if (!this.hasEndAtInputTarget || !this.hasErrorMessageTarget) return
    const inputDateValue = this.endAtInputTarget.value
    if (!inputDateValue) return

    const normalizedString = inputDateValue.replace(/\//g, '-')
    const inputDate = new Date(normalizedString)
    const now = new Date()

    if (inputDate >= now) {
      this.errorMessageTarget.classList.add("hidden")
    } else {
      this.errorMessageTarget.classList.remove("hidden")
    }
  }
}