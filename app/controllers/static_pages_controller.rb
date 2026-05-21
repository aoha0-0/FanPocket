class StaticPagesController < ApplicationController
  # topアクションのみ、ログインなしでもアクセス可能にする
  skip_before_action :authenticate_user!, only: [:top]

  def top
  end

  def test_mail
  # 即席でメールを送信するコマンド
  ActionMailer::Base.mail(
    from: "info@fanpocket.net", 
    to: "あなたの実際のGmailアドレス@gmail.com", # ←ご自身のGmailに書き換えてください
    subject: "本番環境からの疎通テスト", 
    body: "Resendと独自ドメインの紐付けテストです。これが届いていれば成功です！"
  ).deliver_now

  render plain: "テストメールを送信しました！Gmailを確認してください。"
end

end
