# frozen_string_literal: true

class User < ApplicationRecord
  attr_accessor :omniauth_provider

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
  has_many :notifications, dependent: :destroy

  after_create_commit :send_welcome_email, if: -> { email.present? }

  def email_required?
    omniauth_provider != 'line'
  end

  def self.from_omniauth(auth)
    social_account = find_social_account(auth)

    return { user: social_account.user, created: false } if social_account

    user = create_user_with_social_account(auth)

    { user: user, created: true }
  end

  def self.find_social_account(auth)
    SocialAccount.find_by(
      provider: auth.provider,
      uid: auth.uid
    )
  end

  def self.create_user_with_social_account(auth)
    transaction do
      user = create!(user_attributes_from(auth))

      user.social_accounts.create!(
        social_account_attributes_from(auth)
      )

      user
    end
  end

  def self.user_attributes_from(auth)
    {
      email: auth.info.email.presence,
      password: Devise.friendly_token[0, 20],
      omniauth_provider: auth.provider
    }
  end

  def self.social_account_attributes_from(auth)
    {
      provider: auth.provider,
      uid: auth.uid
    }
  end

  private_class_method :find_social_account,
                       :create_user_with_social_account,
                       :user_attributes_from,
                       :social_account_attributes_from

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
