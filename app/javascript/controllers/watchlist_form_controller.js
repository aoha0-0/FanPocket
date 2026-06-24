import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ 
    "titleInput", "titleErrorMessage", 
    "startAtInput", "startErrorMessage", 
    "endAtInput", "errorMessage" 
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