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

    this.renderSuggestionGroup("受付開始", startSuggestions)
    this.renderSuggestionGroup("受付締切", endSuggestions)
    this.renderSuggestionGroup("候補日", otherSuggestions)
  }
  
  renderSuggestionGroup(title, suggestions) {
    if (suggestions.length === 0) return

    const group = document.createElement("div")
    group.className = "w-full mt-2"

    const heading = document.createElement("p")
    heading.textContent = title
    heading.className = "text-xs font-semibold text-neutral-500 mb-1"

    const buttonWrapper = document.createElement("div")
    buttonWrapper.className = "flex flex-wrap gap-2"

    suggestions.forEach((suggestion) => {
    if (suggestion.label.includes("候補")) {
      const candidateGroup = document.createElement("div")
      candidateGroup.className = "flex flex-col items-start gap-1"

      const button = document.createElement("button")
      button.type = "button"
      button.textContent = `${suggestion.label.replace(/^候補: /, "")} ▾`
      button.className = "btn btn-xs btn-outline btn-primary normal-case font-normal"

      button.addEventListener("click", () => {
        this.element.querySelectorAll(".date-choice-buttons").forEach(element => element.remove())

        const choiceContainer = document.createElement("div")
        choiceContainer.className = "date-choice-buttons flex flex-col items-center gap-2 mt-2"

        const message = document.createElement("p")
        message.textContent = "どちらに入力しますか？"
        message.className = "text-xs text-gray-500 "

        const startButton = document.createElement("button")
        startButton.type = "button"
        startButton.textContent = "開始日時へ"
        startButton.className = "btn btn-xs btn-outline btn-secondary normal-case font-normal"

        const endButton = document.createElement("button")
        endButton.type = "button"
        endButton.textContent = "締切日時へ"
        endButton.className = "btn btn-xs btn-outline btn-accent normal-case font-normal"

        const buttonRow = document.createElement("div")
        buttonRow.className = "flex gap-2"

        startButton.addEventListener("click", () => {
          this.insertDateTime("開始", suggestion.value)
        })

        endButton.addEventListener("click", () => {
          this.insertDateTime("締切", suggestion.value)
        })

        buttonRow.appendChild(startButton)
        buttonRow.appendChild(endButton)

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
    button.className = "btn btn-xs btn-outline btn-primary normal-case font-normal"

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