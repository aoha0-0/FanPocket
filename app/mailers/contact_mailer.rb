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

    reply_email = @user&.email.presence || @contact.email.presence
    mail_headers[:reply_to] = reply_email if reply_email

    mail(**mail_headers)
  end
end
