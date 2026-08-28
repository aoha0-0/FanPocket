# frozen_string_literal: true

class ContactMailer < ApplicationMailer
  def notification(contact, user)
    @contact = contact
    @user = user
    @category_label = Contact::CATEGORIES.fetch(@contact.category)

    mail_headers = {
      to: ENV.fetch('CONTACT_EMAIL'),
      subject: "【FanPocket】#{@category_label}のお問い合わせ"
    }
    mail_headers[:reply_to] = @user.email if @user.email.present?

    mail(**mail_headers)
  end
end
