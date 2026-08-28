# frozen_string_literal: true

class ContactsController < ApplicationController
  CONTACT_SEND_INTERVAL = 60.seconds

  def new
    @contact = Contact.new
  end

  def create
    @contact = Contact.new(contact_params)

    if recently_sent?
      flash.now[:alert] = '続けて送信する場合は、少し時間を空けてください'
      render :new, status: :too_many_requests
    elsif @contact.valid?
      send_contact
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def contact_params
    params.require(:contact).permit(:category, :content)
  end

  def recently_sent?
    sent_at = session[:contact_sent_at]
    sent_at.present? && Time.current.to_i - sent_at.to_i < CONTACT_SEND_INTERVAL
  end

  def send_contact
    ContactMailer.notification(@contact, current_user).deliver_now
    session[:contact_sent_at] = Time.current.to_i

    redirect_to settings_path, notice: 'お問い合わせを送信しました'
  end
end
