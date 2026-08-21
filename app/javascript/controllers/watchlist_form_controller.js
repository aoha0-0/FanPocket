import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ 
    "titleInput", "titleErrorMessage",
    "urlInput", "fetchButton", "noticeMessage", 
    "startAtInput", "endAtInput", "endAtRealtimeError",
    "suggestionsContainer" 
  ]

  // 画面が表示された時、およびTurboで画面が書き換わった時に毎回確実に動く魔法
  initialize() {
    this.checkTitle = this.checkTitle.bind(this)
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
          this.startAtInputTarget._flatpickr.set('onChange', () => this.checkStartDate())
          this.startAtInputTarget._flatpickr.set('onClose', () => this.checkStartDate())
        }
        
        if (endConnected) {
          this.endAtInputTarget._flatpickr.set('onChange', () => this.checkDate())
          this.endAtInputTarget._flatpickr.set('onClose', () => this.checkDate())
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

      console.log(data)

      if (response.ok && data.suggestions.length > 0) {
        this.renderDateSuggestions(data.suggestions)
      }
    } catch (error) {
      console.error(error)
    }
  }

  // ✨ ボタンを画面に生成
  renderDateSuggestions(suggestions) {
    if (!this.hasSuggestionsContainerTarget) return

    this.suggestionsContainerTarget.innerHTML = ""

    const startSuggestions = suggestions.filter(suggestion => suggestion.label.includes("開始"))
    const endSuggestions = suggestions.filter(suggestion => suggestion.label.includes("締切"))
    const otherSuggestions = suggestions.filter(suggestion => suggestion.label.includes("候補"))

    this.renderSuggestionGroup("開始日時", startSuggestions)
    this.renderSuggestionGroup("締切日時", endSuggestions)
    this.renderSuggestionGroup("候補日", otherSuggestions)
  }
  
  renderSuggestionGroup(title, suggestions) {
    if (suggestions.length === 0) return

    const group = document.createElement("div")
    group.className = "w-full mt-2"

    const heading = document.createElement("p")
    heading.textContent = title
    heading.className = "text-xs font-medium text-primary/60 mb-1.5"

    const buttonWrapper = document.createElement("div")
    buttonWrapper.className = "flex flex-wrap gap-2"

    suggestions.forEach((suggestion) => {
      if (suggestion.label.includes("候補")) {
        const candidateGroup = document.createElement("div")
        candidateGroup.className = "flex flex-col items-start gap-1"

        const button = document.createElement("button")
        button.type = "button"
        button.textContent = `${suggestion.label.replace(/^候補: /, "")} ▾`
        button.className = "candidate-button btn btn-xs btn-soft btn-info normal-case font-normal"

        button.addEventListener("click", () => {
          this.element.querySelectorAll(".candidate-button").forEach((candidateButton) => {
            candidateButton.textContent = candidateButton.textContent.replace("▴", "▾")
          })

        button.textContent = `${suggestion.label.replace(/^候補: /, "")} ▴`

        this.element.querySelectorAll(".date-choice-buttons").forEach(element => element.remove())

        const choiceContainer = document.createElement("div")
        choiceContainer.className = "date-choice-buttons relative flex flex-col items-center gap-2 mt-2 p-3 rounded-xl bg-white border border-primary/20 shadow-sm"

        const arrow = document.createElement("div")
        arrow.className = "absolute -top-2 left-5 w-3 h-3 rotate-45 bg-white border-l border-t border-primary/20"

        const message = document.createElement("p")
        message.textContent = "どちらに入力しますか？"
        message.className = "text-xs text-gray-500"

        const startButton = document.createElement("button")
        startButton.type = "button"
        startButton.textContent = "開始日時にする"
        startButton.className = "btn btn-xs btn-soft btn-accent normal-case font-normal"

        startButton.addEventListener("click", () => {
          this.insertDateTime("開始", suggestion.value)
          choiceContainer.remove()
          button.textContent = `${suggestion.label.replace(/^候補: /, "")} ▾`
        })

        const endButton = document.createElement("button")
        endButton.type = "button"
        endButton.textContent = "締切日時にする"
        endButton.className = "btn btn-xs btn-soft btn-secondary normal-case font-normal"

        endButton.addEventListener("click", () => {
          this.insertDateTime("締切", suggestion.value)
          choiceContainer.remove()
          button.textContent = `${suggestion.label.replace(/^候補: /, "")} ▾`
        })

        const buttonRow = document.createElement("div")
        buttonRow.className = "flex gap-2"

        buttonRow.appendChild(startButton)
        buttonRow.appendChild(endButton)

        choiceContainer.appendChild(arrow)
        choiceContainer.appendChild(message)
        choiceContainer.appendChild(buttonRow)

        candidateGroup.appendChild(choiceContainer)
      })

      candidateGroup.appendChild(button)
      buttonWrapper.appendChild(candidateGroup)

      return
    }

    const button = document.createElement("button")
    button.type = "button"
    button.textContent = suggestion.label.replace(/^開始: /, "").replace(/^締切: /, "")
    
    if (title === "開始日時") {
      button.className = "btn btn-xs btn-soft btn-accent normal-case font-normal"
    } else if (title === "締切日時") {
      button.className = "btn btn-xs btn-soft btn-secondary normal-case font-normal"
    }

    button.addEventListener("click", () => {
      this.insertDateTime(suggestion.label, suggestion.value)
    })

      buttonWrapper.appendChild(button)
    })

    group.appendChild(heading)
    group.appendChild(buttonWrapper)
    this.suggestionsContainerTarget.appendChild(group)
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
    this.checkDate()
  }

  // 締切日時のチェック 
  checkDate() {
    if (!this.hasEndAtInputTarget || !this.hasEndAtRealtimeErrorTarget) return

    const endAtValue = this.endAtInputTarget.value
    if (!endAtValue) {
      this.endAtRealtimeErrorTarget.classList.add("hidden")
      return
    }

    const endAt = new Date(endAtValue.replace(/\//g, "-"))
    const now = new Date()

    let errorMessage = ""

    if (endAt < now) {
      errorMessage = "締切日時は未来の日時を選択してください"
    }

    if (this.hasStartAtInputTarget) {
      const startAtValue = this.startAtInputTarget.value

      if (startAtValue) {
        const startAt = new Date(startAtValue.replace(/\//g, "-"))

        if (endAt <= startAt) {
          errorMessage = "締切日時は開始日時より後の日時を選択してください"
        }
      }
    }

    if (errorMessage) {
      this.endAtRealtimeErrorTarget.innerHTML = `
        <span class="material-symbols-outlined text-sm">info</span>
        ${errorMessage}
      `
      this.endAtRealtimeErrorTarget.classList.remove("hidden")
    } else {
      this.endAtRealtimeErrorTarget.classList.add("hidden")
    }
  }
}