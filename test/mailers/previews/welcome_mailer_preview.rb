# Preview all emails at http://localhost:3000/rails/mailers/welcome_mailer
class WelcomeMailerPreview < ActionMailer::Preview
  def send_welcome_email
  # プレビュー表示用に、データベースの最初のユーザー（いなければ仮のユーザー）を渡します
    user = User.first || User.new(email: "test@example.com")
    
    WelcomeMailer.send_welcome_email(user)
  end
end
