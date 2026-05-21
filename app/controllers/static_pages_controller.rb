class StaticPagesController < ApplicationController
  # topアクションのみ、ログインなしでもアクセス可能にする
  skip_before_action :authenticate_user!, only: [:top]

  def top
  end

  def test_mail
  # 即席でメールを送信するコマンド
  ActionMailer::Base.mail(
    from: "info@fanpocket.net", 
    to: "aquarium.swing@gmail.com", 
    subject: "本番環境からの疎通テスト", 
    body: "Resendと独自ドメインの紐付けテストです。これが届いていれば成功です！"
  ).deliver_now

  render plain: "テストメールを送信しました！Gmailを確認してください。"
end

end
