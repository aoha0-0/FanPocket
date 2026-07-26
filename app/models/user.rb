# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable,
         :omniauthable,
         omniauth_providers: %i[google_oauth2 line]

  has_many :watchlists, dependent: :destroy
  has_many :social_accounts, dependent: :destroy

  after_create_commit :send_welcome_email, if: -> { email.present? }

  def email_required?
    provider != 'line'
  end

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
    end
  end

  def link_social_account(auth)
    return :already_linked if already_linked?(auth)
    return :taken if linked_to_other_user?(auth)

    create_social_account(auth)

    :success
  end

  def linked_with?(provider)
    social_accounts.exists?(provider:)
  end

  private

  def send_welcome_email
    WelcomeMailer.send_welcome_email(self).deliver_now
  end

  def already_linked?(auth)
    social_accounts.exists?(provider: auth.provider)
  end

  def linked_to_other_user?(auth)
    SocialAccount.exists?(provider: auth.provider, uid: auth.uid)
  end

  def create_social_account(auth)
    social_accounts.create!(
      provider: auth.provider,
      uid: auth.uid
    )
  end
end
