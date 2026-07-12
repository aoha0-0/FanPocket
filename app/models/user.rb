# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable,
         omniauth_providers: [:google_oauth2]

  has_many :watchlists, dependent: :destroy

  after_create_commit :send_welcome_email

  def self.from_omniauth(auth)
    find_or_create_by(provider: auth.provider, uid: auth.uid) do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
    end
  end

  private

  def send_welcome_email
    WelcomeMailer.send_welcome_email(self).deliver_later
  end
end
