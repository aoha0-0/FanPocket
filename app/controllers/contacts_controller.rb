# frozen_string_literal: true

class ContactsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[new create]

  CONTACT_SEND_INTERVAL = 60.seconds

  def new
    @contact = Contact.new(email_required: current_user&.email.blank?)
  end

  def create
    @contact = Contact.new(
      contact_params.merge(email_required: current_user&.email.blank?)
    )

    return head :ok if spam_contact?
    return reject_recent_contact if recently_sent?

    if @contact.valid?
      send_contact
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  def contact_params
    params.require(:contact).permit(:category, :content, :email, :website)
  end

  def recently_sent?
    sent_at = session[:contact_sent_at]
    sent_at.present? && Time.current.to_i - sent_at.to_i < CONTACT_SEND_INTERVAL
  end

  def send_contact
    ContactMailer.notification(@contact, current_user).deliver_now
    session[:contact_sent_at] = Time.current.to_i

    redirect_path = user_signed_in? ? settings_path : new_user_session_path
    redirect_to redirect_path, notice: 'お問い合わせを送信しました'
  end

  def spam_contact?
    @contact.website.present?
  end

  def reject_recent_contact
    flash.now[:alert] = '続けて送信する場合は、少し時間を空けてください'
    render :new, status: :too_many_requests
  end
end
